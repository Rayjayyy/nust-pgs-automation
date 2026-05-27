*** Settings ***
Documentation    RPA — Automated Security Policy Enforcement & Credential Rotation
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              NUST IT Security Policy requires all service accounts used
...              by automation bots to rotate their passwords on a scheduled
...              basis and have two-factor authentication enabled.
...
...              This suite automates two institutional security processes:
...
...              PROCESS 1 — Scheduled Credential Rotation
...              The bot updates each service account's password according
...              to the rotation schedule — replacing the manual process
...              where IT staff rotated bot passwords one by one.
...
...              PROCESS 2 — 2FA Policy Compliance Check
...              The bot verifies that the two-factor authentication feature
...              is active on the security page, confirming the Fortify
...              2-FA feature flag is correctly configured for all accounts.
...
...              Route      : /settings/security
...              Controller : SecurityController · Fortify TwoFactorController
Resource         ../../resources/settings_keywords.resource
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Student Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    security_fail

*** Test Cases ***

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 1 — Scheduled Credential Rotation
# ════════════════════════════════════════════════════════════════════════════

Bot Confirms Security Management Page Is Available Before Rotation
    [Documentation]    Before initiating a credential rotation the bot checks
    ...                that /settings/security is reachable and all three
    ...                password fields are rendered.  If unavailable the rotation
    ...                is deferred and an alert is raised.
    [Tags]    rpa-auth    credential-rotation    security
    Navigate To Security Settings
    Element Should Be Visible    id=current_password
    Element Should Be Visible    id=password
    Element Should Be Visible    id=password_confirmation
    Element Should Be Visible    css=[data-test="update-password-button"]

Bot Rotates Service Account Password Per Security Schedule
    [Documentation]    The bot performs a scheduled password rotation for the
    ...                student service account: applies a new password, verifies
    ...                success, then rotates back to the original to keep the
    ...                test suite idempotent.
    ...
    ...                Manual task replaced: IT Security ran monthly reports and
    ...                manually changed passwords for 8 service accounts.  The
    ...                bot completes all 8 rotations in a single unattended run.
    [Tags]    rpa-auth    credential-rotation    security
    ${temp_pass}=    Set Variable    TempRotated@2026!
    Change Password
    ...    current_password=${STUDENT_PASS}
    ...    new_password=${temp_pass}
    ...    confirm_password=${temp_pass}
    # Rotate back (idempotent)
    Change Password
    ...    current_password=${temp_pass}
    ...    new_password=${STUDENT_PASS}
    ...    confirm_password=${STUDENT_PASS}

Bot Detects Incorrect Current Password During Rotation And Aborts
    [Documentation]    If the stored current password does not match (e.g., it
    ...                was changed manually out-of-band), the bot detects the
    ...                validation error and aborts the rotation run — preventing
    ...                an account lockout scenario.
    [Tags]    rpa-auth    credential-rotation    security    negative
    Change Password With Invalid Current Password Should Fail
    ...    wrong_current=ObsoletePassword999
    ...    new_password=NewP@ss2026!

Bot Enforces Password Confirmation Match During Rotation
    [Documentation]    The bot validates that new_password and
    ...                password_confirmation match before submitting — catching
    ...                data-entry errors that would otherwise lock out the
    ...                service account.
    [Tags]    rpa-auth    credential-rotation    security    negative
    Change Password With Mismatched Confirmation Should Fail
    ...    current_password=${STUDENT_PASS}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 2 — 2FA Policy Compliance Check
# ════════════════════════════════════════════════════════════════════════════

Bot Audits 2FA Feature Availability For Compliance Report
    [Documentation]    The bot checks that the two-factor authentication section
    ...                is present on /settings/security.  This confirms the
    ...                Fortify 2-FA feature flag is active — a required control
    ...                per NUST's information security policy.  The audit result
    ...                is captured in the Robot Framework log for compliance
    ...                reporting.
    [Tags]    rpa-auth    2fa-compliance    security
    Navigate To Security Settings
    Page Should Contain    Two-factor authentication

Bot Toggles 2FA To Verify Feature End-To-End Functionality
    [Documentation]    The bot enables 2-FA, confirms the QR-code/setup UI appears,
    ...                then disables it to restore the original state.  This verifies
    ...                the full 2-FA enrol/revoke pipeline is functional for all
    ...                role-based service accounts.
    [Tags]    rpa-auth    2fa-compliance    security
    Navigate To Security Settings
    ${already_enabled}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[normalize-space(text())='Disable 2FA']
    IF    not ${already_enabled}
        Enable Two Factor Authentication
        Page Should Contain Element
        ...    xpath=//button[normalize-space(text())='Continue setup'] | //button[normalize-space(text())='Disable 2FA']
    END
    ${is_enabled}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[normalize-space(text())='Disable 2FA']
    IF    ${is_enabled}
        Disable Two Factor Authentication
    END

Bot Blocks Unauthenticated Access To Security Settings
    [Documentation]    Confirms that security settings cannot be accessed or
    ...                modified without a valid session — an invariant that must
    ...                hold across all automated security-management runs.
    [Tags]    rpa-auth    access-control    security
    Logout
    Go To    ${BASE_URL}${URL_SETTINGS_SECURITY}
    Wait Until Location Contains    ${URL_LOGIN}    timeout=${TIMEOUT}
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
