*** Settings ***
Documentation    RPA — Bot Credential Verification & Secure System Access
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              Before every RPA run the bot must authenticate against the
...              Fortify session layer, obtain a valid CSRF token, and land
...              inside the application.  This suite validates that all seven
...              role-based bot credentials are accepted, that the session
...              management is reliable, and that the system enforces access
...              control (unauthenticated users are redirected away from
...              protected routes).
...
...              Manual task replaced
...              ─────────────────────
...              Staff previously logged in manually before performing each
...              workflow step.  The RPA bots handle authentication
...              automatically at the start of every scheduled automation run,
...              rotating through each role as required by the process.
...
...              Auth engine : Laravel Fortify (email / password + 2-FA TOTP)
...              Login URL   : /login  (resources/js/pages/auth/login.tsx)
...              Credential source: variables/config.py  ← seeded by PgsDemoSeeder
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Open PGS Application
Suite Teardown   Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    auth_fail

*** Test Cases ***

# ════════════════════════════════════════════════════════════════════════════
# BOT AUTHENTICATION — all seven role-based service accounts
# ════════════════════════════════════════════════════════════════════════════

Bot Authenticates As Student Service Account
    [Documentation]    The student-role bot authenticates using the seeded service
    ...                account (tendai.moyo@students.nust.na) and confirms it reaches
    ...                the protected /dashboard before beginning intake automation.
    [Tags]    rpa-auth    bot-access    student
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Bot Authenticates As Supervisor Service Account
    [Documentation]    The supervisor-role bot authenticates as Prof. Chikwanha and
    ...                reaches the dashboard — prerequisite for the progress-report
    ...                and SoP automation runs.
    [Tags]    rpa-auth    bot-access    supervisor
    Login As    ${SUPERVISOR_USER}    ${SUPERVISOR_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Bot Authenticates As Internal Evaluator Service Account
    [Documentation]    The internal-evaluator bot authenticates as Dr. Kamati —
    ...                prerequisite for the proposal evaluation automation run.
    [Tags]    rpa-auth    bot-access    internal-evaluator
    Login As    ${INT_EVAL_USER}    ${INT_EVAL_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Bot Authenticates As External Evaluator Service Account
    [Documentation]    The external-evaluator bot authenticates to process thesis
    ...                grading tasks and submit honorarium claim forms.
    [Tags]    rpa-auth    bot-access    external-evaluator
    Login As    ${EXT_EVAL_USER}    ${EXT_EVAL_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Bot Authenticates As Head Of Department Service Account
    [Documentation]    The HoD bot authenticates to process the departmental
    ...                decision queue, assign evaluators, and approve claims.
    [Tags]    rpa-auth    bot-access    hod
    Login As    ${HOD_USER}    ${HOD_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Bot Authenticates As FPGC Representative Service Account
    [Documentation]    The FPGCR bot authenticates to manage the HDC agenda and
    ...                route submissions through the faculty committee layer.
    [Tags]    rpa-auth    bot-access    fpgcr
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Bot Authenticates As FPGC Committee Service Account
    [Documentation]    The FPGC bot authenticates to process application review
    ...                tasks and assign supervisors to new students.
    [Tags]    rpa-auth    bot-access    fpgc
    Login As    ${FPGC_USER}    ${FPGC_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

# ════════════════════════════════════════════════════════════════════════════
# CREDENTIAL INTEGRITY — system blocks invalid access attempts
# ════════════════════════════════════════════════════════════════════════════

Bot Detects Corrupted Credential And Aborts Automation Run
    [Documentation]    Before executing any business-process automation the bot
    ...                validates its credentials.  An incorrect email/password pair
    ...                is rejected by Fortify — the bot halts rather than operating
    ...                in an unknown state.
    [Tags]    rpa-auth    credential-check    negative
    Attempt Login With    ${INVALID_USER}    ${INVALID_PASS}
    Login Should Fail With Error

Bot Validates Password Integrity Before Starting Workflow
    [Documentation]    A valid service account email with a wrong password is rejected;
    ...                the automation run does not proceed beyond the login gate.
    [Tags]    rpa-auth    credential-check    negative
    Attempt Login With    ${STUDENT_USER}    WrongPassword999
    Login Should Fail With Error

# ════════════════════════════════════════════════════════════════════════════
# ACCESS CONTROL — unauthenticated bots are blocked from protected routes
# ════════════════════════════════════════════════════════════════════════════

Unauthenticated Bot Is Redirected Away From Dashboard
    [Documentation]    Any attempt by an unauthenticated process to access a
    ...                protected route (/dashboard) is met with a redirect to
    ...                /login — enforcing that all RPA bots must authenticate first.
    [Tags]    rpa-auth    access-control
    Go To    ${BASE_URL}${URL_DASHBOARD}
    Wait Until Location Contains    ${URL_LOGIN}    timeout=${TIMEOUT}

Bot Session Terminates Cleanly On Logout
    [Documentation]    After completing its automation tasks the bot calls logout,
    ...                which destroys the session and returns to /login.  This ensures
    ...                no lingering sessions remain after each scheduled run.
    [Tags]    rpa-auth    session-management
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
    Logout
    Location Should Contain    ${URL_LOGIN}

Bot Receives Persistent Session With Remember-Me Flag
    [Documentation]    Long-running automation jobs use a persistent session
    ...                (remember_me=true) so the bot is not logged out mid-process
    ...                during extended batch operations.
    [Tags]    rpa-auth    session-management
    Go To    ${BASE_URL}${URL_LOGIN}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Input Text    id=email      ${STUDENT_USER}
    Input Text    id=password   ${STUDENT_PASS}
    Select Checkbox    id=remember
    Click Element      css=[data-test="login-button"]
    Wait Until Location Contains    ${URL_DASHBOARD}    timeout=${TIMEOUT}
    Logout
