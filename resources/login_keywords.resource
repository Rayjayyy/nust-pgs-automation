*** Settings ***
Documentation    Role-specific login helpers for the NUST PGS automation suite.
...
...              Each keyword logs in with the correct seeded credentials and
...              verifies the browser has landed on the dashboard.
...
...              Source references
...              ─────────────────
...              resources/js/pages/auth/login.tsx   – id=email, id=password,
...                                                    data-test="login-button"
...              resources/js/pages/auth/register.tsx – id=first_name, id=last_name,
...                                                    id=email, id=password,
...                                                    id=password_confirmation,
...                                                    data-test="register-user-button"
...              routes/web.php + Fortify defaults   – /login, /register, /logout
Resource         common.resource
Variables        ../variables/config.py

*** Keywords ***
# ── Role logins ───────────────────────────────────────────────────────────────

Student Login
    [Documentation]    Logs in as the demo student (Tendai Moyo).
    Open PGS Application
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}

Supervisor Login
    [Documentation]    Logs in as the demo supervisor (Prof. James Chikwanha).
    Open PGS Application
    Login As    ${SUPERVISOR_USER}    ${SUPERVISOR_PASS}

Internal Evaluator Login
    [Documentation]    Logs in as the demo internal evaluator (Dr. Elizabeth Kamati).
    Open PGS Application
    Login As    ${INT_EVAL_USER}    ${INT_EVAL_PASS}

External Evaluator Login
    [Documentation]    Logs in as the seed external evaluator.
    Open PGS Application
    Login As    ${EXT_EVAL_USER}    ${EXT_EVAL_PASS}

HoD Login
    [Documentation]    Logs in as the seed Head of Department.
    Open PGS Application
    Login As    ${HOD_USER}    ${HOD_PASS}

FPGCR Login
    [Documentation]    Logs in as the seed FPGC Representative.
    Open PGS Application
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}

FPGC Login
    [Documentation]    Logs in as the seed FPGC member.
    Open PGS Application
    Login As    ${FPGC_USER}    ${FPGC_PASS}

# ── Negative login helpers ─────────────────────────────────────────────────────

Attempt Login With
    [Documentation]    Fills the login form with given credentials and clicks submit.
    ...                Does NOT assert a destination – caller must check outcome.
    [Arguments]    ${email}    ${password}
    Go To    ${BASE_URL}${URL_LOGIN}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Input Text    id=email       ${email}
    Input Text    id=password    ${password}
    Click Element    css=[data-test="login-button"]

Login Should Fail With Error
    [Documentation]    Asserts that an invalid login attempt shows a validation message
    ...                and does NOT navigate away from /login.
    Location Should Contain    ${URL_LOGIN}
    # Fortify renders a flash message or Inertia error – check both possibilities
    Page Should Contain Element
    ...    css=[role="alert"], xpath=//*[contains(@class,'text-red') or contains(@class,'alert')]

# ── Registration helper ────────────────────────────────────────────────────────

Fill And Submit Registration Form
    [Documentation]    Fills the /register form with the supplied values and submits.
    [Arguments]
    ...    ${first_name}
    ...    ${last_name}
    ...    ${email}
    ...    ${password}
    ...    ${password_confirm}
    Go To    ${BASE_URL}${URL_REGISTER}
    Wait Until Element Is Visible    id=first_name    timeout=${TIMEOUT}
    Input Text    id=first_name             ${first_name}
    Input Text    id=last_name              ${last_name}
    Input Text    id=email                  ${email}
    Input Text    id=password               ${password}
    Input Text    id=password_confirmation  ${password_confirm}
    Click Element    css=[data-test="register-user-button"]
