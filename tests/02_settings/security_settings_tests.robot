*** Settings ***
Documentation    Security settings test suite – password change and 2-FA.
...
...              Page under test : /settings/security
...              Source          : resources/js/pages/settings/security.tsx
...
...              Element references (from source code)
...              ──────────────────────────────────────
...              id=current_password                     – current password input
...              id=password                             – new password input
...              id=password_confirmation                – confirm new password
...              css=[data-test="update-password-button"] – Save password button
...              xpath=//button[text()='Enable 2FA']     – enable 2-FA button
...              xpath=//button[text()='Disable 2FA']    – disable 2-FA button
...
...              Controller : SecurityController (update password)
...              Fortify    : TwoFactorAuthenticationController
Resource         ../../resources/settings_keywords.resource
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Student Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    security_fail

*** Test Cases ***

Security Page Renders Password Change Form
    [Documentation]    /settings/security shows all three password fields and the
    ...                Save password button.
    [Tags]    smoke    settings    security    password
    Navigate To Security Settings
    Element Should Be Visible    id=current_password
    Element Should Be Visible    id=password
    Element Should Be Visible    id=password_confirmation
    Element Should Be Visible    css=[data-test="update-password-button"]

Security Page Is Inaccessible Without Login
    [Documentation]    A guest hitting /settings/security is redirected to /login.
    [Tags]    regression    settings    security
    Logout
    Go To    ${BASE_URL}${URL_SETTINGS_SECURITY}
    Wait Until Location Contains    ${URL_LOGIN}    timeout=${TIMEOUT}
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}

User Can Change Password Successfully
    [Documentation]    Uses the correct current password, sets a valid new password,
    ...                then restores the original to keep the suite idempotent.
    [Tags]    smoke    settings    security    password
    ${temp_pass}=    Set Variable    TempP@ss2026!
    Change Password
    ...    current_password=${STUDENT_PASS}
    ...    new_password=${temp_pass}
    ...    confirm_password=${temp_pass}
    # Restore original password
    Change Password
    ...    current_password=${temp_pass}
    ...    new_password=${STUDENT_PASS}
    ...    confirm_password=${STUDENT_PASS}

Wrong Current Password Is Rejected
    [Documentation]    A wrong current_password value must trigger a validation error
    ...                on id=current_password.
    [Tags]    regression    settings    security    password    negative
    Change Password With Invalid Current Password Should Fail
    ...    wrong_current=TotallyWrongPassword123
    ...    new_password=NewP@ss2026!

Mismatched New Password Confirmation Is Rejected
    [Documentation]    When new_password != password_confirmation the Inertia response
    ...                returns a validation error on id=password_confirmation.
    [Tags]    regression    settings    security    password    negative
    Change Password With Mismatched Confirmation Should Fail
    ...    current_password=${STUDENT_PASS}

Password Change With Empty New Password Shows Validation Error
    [Documentation]    Leaving id=password blank triggers the required validation.
    [Tags]    regression    settings    security    password    negative
    Navigate To Security Settings
    Input Text    id=current_password      ${STUDENT_PASS}
    Clear Element Text    id=password
    Input Text    id=password_confirmation ${STUDENT_PASS}
    Click Element    css=[data-test="update-password-button"]
    Field Should Show Validation Error    password

# ── Two-Factor Authentication ─────────────────────────────────────────────────

Security Page Shows 2FA Section When Feature Is Enabled
    [Documentation]    When canManageTwoFactor=true the 2-FA section heading is visible.
    [Tags]    smoke    settings    security    2fa
    Navigate To Security Settings
    # 2-FA section renders when the Fortify feature flag is active
    Page Should Contain    Two-factor authentication

User Can Toggle Two Factor Authentication On And Off
    [Documentation]    Enables 2-FA (which generates a QR code), then immediately
    ...                disables it so the suite remains idempotent.
    ...                Full TOTP confirmation is not automated (requires a live OTP).
    [Tags]    regression    settings    security    2fa
    Navigate To Security Settings
    ${already_enabled}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[normalize-space(text())='Disable 2FA']
    IF    not ${already_enabled}
        Enable Two Factor Authentication
        # QR code modal appears; we only verify the modal/button is present
        Page Should Contain Element
        ...    xpath=//button[normalize-space(text())='Continue setup'] | //button[normalize-space(text())='Disable 2FA']
    END
    # Disable to restore original state
    ${is_enabled}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[normalize-space(text())='Disable 2FA']
    IF    ${is_enabled}
        Disable Two Factor Authentication
    END
