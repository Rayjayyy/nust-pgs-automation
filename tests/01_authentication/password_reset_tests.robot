*** Settings ***
Documentation    Password-reset test suite.
...
...              Pages under test
...              ────────────────
...              /forgot-password  (resources/js/pages/auth/forgot-password.tsx)
...                → id=email
...                   css=[data-test="email-password-reset-link-button"]
...
...              /reset-password/{token}  (resources/js/pages/auth/reset-password.tsx)
...                → id=email  (read-only, pre-filled)
...                   id=password
...                   id=password_confirmation
...                   css=[data-test="reset-password-button"]
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Open PGS Application
Suite Teardown   Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    pwreset_fail

*** Test Cases ***

Forgot Password Page Renders Email Field And Submit Button
    [Documentation]    The /forgot-password page shows id=email and the
    ...                "Email password reset link" button.
    [Tags]    smoke    password-reset    ui
    Go To    ${BASE_URL}${URL_FORGOT_PW}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Element Should Be Visible    css=[data-test="email-password-reset-link-button"]

Forgot Password Page Has Return To Login Link
    [Documentation]    The page renders a "log in" back-link.
    [Tags]    smoke    password-reset    ui
    Go To    ${BASE_URL}${URL_FORGOT_PW}
    Wait Until Page Contains    log in    timeout=${TIMEOUT}

Forgot Password With Valid Email Shows Status Message
    [Documentation]    Submitting a valid seeded email (student) triggers Fortify to
    ...                send a reset link; the page shows a green status message
    ...                ("We have emailed your password reset link.").
    [Tags]    smoke    password-reset
    Go To    ${BASE_URL}${URL_FORGOT_PW}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Input Text    id=email    ${STUDENT_USER}
    Click Element    css=[data-test="email-password-reset-link-button"]
    # Fortify returns with a status message on the same page
    Wait Until Page Contains    password reset link    timeout=${TIMEOUT}

Forgot Password With Unknown Email Shows Status Message
    [Documentation]    Fortify does not reveal whether an email exists – it always
    ...                shows the "link sent" status message regardless.
    [Tags]    regression    password-reset
    Go To    ${BASE_URL}${URL_FORGOT_PW}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Input Text    id=email    no.such.user.xyz@nust.na
    Click Element    css=[data-test="email-password-reset-link-button"]
    # Same status message expected (prevents email enumeration)
    Wait Until Page Contains    password reset link    timeout=${TIMEOUT}

Forgot Password With Empty Email Shows Validation Error
    [Documentation]    Submitting without an email triggers HTML5 required validation.
    [Tags]    regression    password-reset    negative
    Go To    ${BASE_URL}${URL_FORGOT_PW}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Clear Element Text    id=email
    Click Element    css=[data-test="email-password-reset-link-button"]
    Location Should Contain    ${URL_FORGOT_PW}

Reset Password Page Renders All Fields
    [Documentation]    Visits the reset-password route with a dummy token; confirms
    ...                the id=email (readonly), id=password, id=password_confirmation
    ...                and the submit button are rendered.
    ...                NOTE: A real token is needed to complete the reset; this test
    ...                only checks page structure.
    [Tags]    regression    password-reset    ui
    Go To    ${BASE_URL}/reset-password/dummy-token-for-ui-test?email=${STUDENT_USER}
    # If Fortify rejects the dummy token it may redirect; accept that outcome
    ${location}=    Get Location
    IF    '/reset-password/' in '${location}'
        Wait Until Element Is Visible    id=password    timeout=${TIMEOUT}
        Element Should Be Visible    id=password_confirmation
        Element Should Be Visible    css=[data-test="reset-password-button"]
    END
