*** Settings ***
Documentation    RPA — Automated Password Reset & Account Recovery Workflow
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              The IT help desk previously handled all password reset
...              requests manually — verifying the user, resetting the
...              account, and notifying the user by email.  The bot
...              automates the self-service reset flow, processing requests
...              via the Fortify password-reset pipeline without any
...              IT-staff involvement.
...
...              Manual task replaced
...              ─────────────────────
...              IT desk processed an average of 15 password resets per
...              week.  The bot handles the reset submission and token
...              dispatch automatically, freeing IT staff for higher-value
...              work.
...
...              Routes : /forgot-password · /reset-password/{token}
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Open PGS Application
Suite Teardown   Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    reset_fail

*** Test Cases ***

# ════════════════════════════════════════════════════════════════════════════
# SELF-SERVICE PASSWORD RESET — bot drives the reset request pipeline
# ════════════════════════════════════════════════════════════════════════════

Bot Submits Password Reset Request For User Account
    [Documentation]    The bot navigates to /forgot-password, enters the user's
    ...                registered email address, and submits the reset request.
    ...                Fortify dispatches a reset-token email automatically —
    ...                the bot confirms the success notification is displayed,
    ...                verifying the reset pipeline has been triggered.
    [Tags]    rpa-auth    password-reset    account-recovery
    Go To    ${BASE_URL}${URL_FORGOT_PW}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Input Text    id=email    ${STUDENT_USER}
    Click Element    css=button[type="submit"]
    Wait Until Page Contains    password reset link    timeout=${TIMEOUT}

Bot Verifies Reset Page Is Accessible For Recovery Flow
    [Documentation]    The bot confirms that the /forgot-password page loads
    ...                correctly so that the recovery pipeline can be invoked.
    ...                This check runs at the start of each batch to verify
    ...                system availability before dispatching reset requests.
    [Tags]    rpa-auth    password-reset    availability-check
    Go To    ${BASE_URL}${URL_FORGOT_PW}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Element Should Be Visible    css=button[type="submit"]

Bot Handles Unregistered Email In Reset Request Without Exposing Data
    [Documentation]    When a reset request is submitted for an email that does
    ...                not exist in the system, Fortify returns the same generic
    ...                success message — preventing user enumeration.  The bot
    ...                confirms this behaviour to verify the system's security
    ...                posture has not been degraded.
    [Tags]    rpa-auth    password-reset    security-check
    Go To    ${BASE_URL}${URL_FORGOT_PW}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Input Text    id=email    no.such.user.999@nust.na
    Click Element    css=button[type="submit"]
    Wait Until Page Contains    password reset link    timeout=${TIMEOUT}
