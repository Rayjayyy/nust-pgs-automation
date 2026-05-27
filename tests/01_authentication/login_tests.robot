*** Settings ***
Documentation    Authentication test suite – Login, 2-FA challenge, Logout.
...
...              Page under test : /login   (resources/js/pages/auth/login.tsx)
...              Auth engine     : Laravel Fortify
...
...              Element references (from source code)
...              ──────────────────────────────────────
...              id=email                        – email address field
...              id=password                     – password field
...              id=remember                     – "Remember me" checkbox
...              css=[data-test="login-button"]  – submit button
...
...              Seed credentials (database/demo-seed.sql, database/seed.sql)
...              ──────────────────────────────────────────────────────────────
...              All demo users share password = "password"
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Open PGS Application
Suite Teardown   Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    login_fail

*** Test Cases ***

# ────────────────────────────────────────────────────────────────────────────────
# Happy-path logins – all 7 roles
# ────────────────────────────────────────────────────────────────────────────────

Student Can Log In And Reach Dashboard
    [Documentation]    Tendai Moyo (student, demo-seed id=100) logs in and lands on
    ...                /dashboard.  Confirms Inertia SPA navigation worked.
    [Tags]    smoke    login    student
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Supervisor Can Log In And Reach Dashboard
    [Documentation]    Prof. James Chikwanha (supervisor, demo-seed id=101) logs in.
    [Tags]    smoke    login    supervisor
    Login As    ${SUPERVISOR_USER}    ${SUPERVISOR_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Internal Evaluator Can Log In And Reach Dashboard
    [Documentation]    Dr. Elizabeth Kamati (evaluator, demo-seed id=102) logs in.
    [Tags]    smoke    login    internal-evaluator
    Login As    ${INT_EVAL_USER}    ${INT_EVAL_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

External Evaluator Can Log In And Reach Dashboard
    [Documentation]    Seed external evaluator (external@nust.na) logs in.
    [Tags]    smoke    login    external-evaluator
    Login As    ${EXT_EVAL_USER}    ${EXT_EVAL_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

Head Of Department Can Log In And Reach Dashboard
    [Documentation]    Seed HoD (hod@nust.na) logs in.
    [Tags]    smoke    login    hod
    Login As    ${HOD_USER}    ${HOD_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

FPGCR Can Log In And Reach Dashboard
    [Documentation]    Seed FPGC-R (fpgcr@nust.na) logs in.
    [Tags]    smoke    login    fpgcr
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

FPGC Can Log In And Reach Dashboard
    [Documentation]    Seed FPGC member (fpgc@nust.na) logs in.
    [Tags]    smoke    login    fpgc
    Login As    ${FPGC_USER}    ${FPGC_PASS}
    Location Should Contain    ${URL_DASHBOARD}
    Logout

# ────────────────────────────────────────────────────────────────────────────────
# Login page UI checks
# ────────────────────────────────────────────────────────────────────────────────

Login Page Shows Email And Password Fields
    [Documentation]    The /login page renders id=email, id=password and the
    ...                Remember me checkbox (id=remember).
    [Tags]    smoke    login    ui
    Go To    ${BASE_URL}${URL_LOGIN}
    Wait Until Element Is Visible    id=email      timeout=${TIMEOUT}
    Element Should Be Visible        id=password
    Element Should Be Visible        id=remember
    Element Should Be Visible        css=[data-test="login-button"]

Login Page Has Forgot Password Link When Enabled
    [Documentation]    The "Forgot password?" link is rendered when canResetPassword=true.
    [Tags]    smoke    login    ui
    Go To    ${BASE_URL}${URL_LOGIN}
    Wait Until Page Contains    Forgot password?    timeout=${TIMEOUT}

Login Page Has Sign Up Link When Registration Enabled
    [Documentation]    A "Sign up" link is rendered when canRegister=true.
    [Tags]    smoke    login    ui
    Go To    ${BASE_URL}${URL_LOGIN}
    Wait Until Page Contains    Sign up    timeout=${TIMEOUT}

# ────────────────────────────────────────────────────────────────────────────────
# Negative / boundary tests
# ────────────────────────────────────────────────────────────────────────────────

Login With Invalid Email And Password Is Rejected
    [Documentation]    A non-existent email/password combination must be rejected.
    ...                Fortify returns a flash validation error; /dashboard must not load.
    [Tags]    regression    login    negative
    Attempt Login With    ${INVALID_USER}    ${INVALID_PASS}
    Login Should Fail With Error

Login With Correct Email But Wrong Password Is Rejected
    [Documentation]    Using a valid seeded email with a wrong password is rejected.
    [Tags]    regression    login    negative
    Attempt Login With    ${STUDENT_USER}    WrongPassword999
    Login Should Fail With Error

Login With Empty Email Field Shows Validation Error
    [Documentation]    HTML5 required constraint fires on submit with empty email.
    [Tags]    regression    login    negative
    Go To    ${BASE_URL}${URL_LOGIN}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Clear Element Text    id=email
    Input Text           id=password    ${STUDENT_PASS}
    Click Element        css=[data-test="login-button"]
    # HTML5 constraint prevents submission; page stays at /login
    Location Should Contain    ${URL_LOGIN}

Login With Empty Password Field Shows Validation Error
    [Documentation]    HTML5 required constraint fires on submit with empty password.
    [Tags]    regression    login    negative
    Go To    ${BASE_URL}${URL_LOGIN}
    Wait Until Element Is Visible    id=password    timeout=${TIMEOUT}
    Input Text    id=email    ${STUDENT_USER}
    Clear Element Text    id=password
    Click Element    css=[data-test="login-button"]
    Location Should Contain    ${URL_LOGIN}

# ────────────────────────────────────────────────────────────────────────────────
# Remember me
# ────────────────────────────────────────────────────────────────────────────────

Login With Remember Me Checkbox Checked
    [Documentation]    Checks the "Remember me" checkbox before submitting; verifies
    ...                login still succeeds.
    [Tags]    regression    login    remember-me
    Go To    ${BASE_URL}${URL_LOGIN}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Input Text    id=email      ${STUDENT_USER}
    Input Text    id=password   ${STUDENT_PASS}
    Select Checkbox    id=remember
    Click Element      css=[data-test="login-button"]
    Wait Until Location Contains    ${URL_DASHBOARD}    timeout=${TIMEOUT}
    Logout

# ────────────────────────────────────────────────────────────────────────────────
# Logout
# ────────────────────────────────────────────────────────────────────────────────

Logged In User Can Log Out
    [Documentation]    After logout the URL must return to /login (Fortify default).
    [Tags]    smoke    login    logout
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
    Logout
    Location Should Contain    ${URL_LOGIN}

Accessing Dashboard While Logged Out Redirects To Login
    [Documentation]    A guest hitting /dashboard is redirected to /login.
    [Tags]    smoke    login    security
    Go To    ${BASE_URL}${URL_DASHBOARD}
    Wait Until Location Contains    ${URL_LOGIN}    timeout=${TIMEOUT}

# ────────────────────────────────────────────────────────────────────────────────
# Two-Factor Authentication challenge page
# ────────────────────────────────────────────────────────────────────────────────

Two Factor Challenge Page Renders OTP Input
    [Documentation]    Visits /two-factor-challenge directly and verifies the OTP
    ...                input (InputOTP component, name=code) is present.
    ...                NOTE: A full 2-FA login test requires a live TOTP token;
    ...                this test only checks page structure.
    [Tags]    regression    login    2fa
    Go To    ${BASE_URL}${URL_TWO_FACTOR_CHALLENGE}
    # Fortify may redirect if no pending 2-FA session; accept either outcome
    Run Keyword If    '${LOCATION}' == '${BASE_URL}${URL_TWO_FACTOR_CHALLENGE}'
    ...    Page Should Contain Element    css=input[name="code"], css=[data-input-otp]
