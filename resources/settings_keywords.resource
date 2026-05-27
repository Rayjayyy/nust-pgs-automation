*** Settings ***
Documentation    Page-level keywords for the Settings module of the NUST PGS system.
...              Covers three implemented sub-pages:
...                • /settings/profile   – update name + email, delete account
...                • /settings/security  – change password, 2-FA (enable / disable)
...                • /settings/appearance – theme toggle
...
...              Source references
...              ─────────────────
...              resources/js/pages/settings/profile.tsx
...                → id=name, id=email, data-test="update-profile-button"
...              resources/js/pages/settings/security.tsx
...                → id=current_password, id=password, id=password_confirmation
...                   data-test="update-password-button"
Resource         common.resource
Variables        ../variables/config.py

*** Keywords ***
# ── Profile settings ─────────────────────────────────────────────────────────

Navigate To Profile Settings
    [Documentation]    Opens /settings/profile and waits for the form to render.
    Navigate To    ${URL_SETTINGS_PROFILE}
    Wait Until Element Is Visible    id=name    timeout=${TIMEOUT}

Update Profile Name
    [Documentation]    Clears the Name field and types the new value.
    [Arguments]    ${new_name}
    Clear Element Text    id=name
    Input Text    id=name    ${new_name}

Update Profile Email
    [Documentation]    Clears the Email field and types the new value.
    [Arguments]    ${new_email}
    Clear Element Text    id=email
    Input Text    id=email    ${new_email}

Save Profile
    [Documentation]    Clicks the Save button on the profile settings form.
    Click Element    css=[data-test="update-profile-button"]
    # Wait for the Inertia response (success flash or page reload)
    Sleep    1s

Update Profile
    [Documentation]    Full workflow: navigate → update name and email → save.
    [Arguments]    ${new_name}    ${new_email}
    Navigate To Profile Settings
    Update Profile Name     ${new_name}
    Update Profile Email    ${new_email}
    Save Profile

Verify Profile Was Saved
    [Documentation]    Re-loads the profile page and checks the Name field value.
    [Arguments]    ${expected_name}
    Navigate To Profile Settings
    ${value}=    Get Element Attribute    id=name    value
    Should Be Equal As Strings    ${value}    ${expected_name}

# ── Security settings – password change ─────────────────────────────────────

Navigate To Security Settings
    [Documentation]    Opens /settings/security and waits for the form to render.
    Navigate To    ${URL_SETTINGS_SECURITY}
    Wait Until Element Is Visible    id=current_password    timeout=${TIMEOUT}

Change Password
    [Documentation]    Fills and submits the Change Password form.
    [Arguments]    ${current_password}    ${new_password}    ${confirm_password}
    Navigate To Security Settings
    Input Text    id=current_password      ${current_password}
    Input Text    id=password              ${new_password}
    Input Text    id=password_confirmation ${confirm_password}
    Click Element    css=[data-test="update-password-button"]
    Sleep    1s

Change Password With Invalid Current Password Should Fail
    [Documentation]    Verifies that a wrong current password is rejected.
    [Arguments]    ${wrong_current}    ${new_password}
    Navigate To Security Settings
    Input Text    id=current_password      ${wrong_current}
    Input Text    id=password              ${new_password}
    Input Text    id=password_confirmation ${new_password}
    Click Element    css=[data-test="update-password-button"]
    Field Should Show Validation Error    current_password

Change Password With Mismatched Confirmation Should Fail
    [Documentation]    Verifies that non-matching new / confirm passwords are rejected.
    [Arguments]    ${current_password}
    Navigate To Security Settings
    Input Text    id=current_password      ${current_password}
    Input Text    id=password              NewPass@001
    Input Text    id=password_confirmation DifferentPass@001
    Click Element    css=[data-test="update-password-button"]
    Field Should Show Validation Error    password_confirmation

# ── Security settings – Two-Factor Authentication (2FA) ──────────────────────

Enable Two Factor Authentication
    [Documentation]    Clicks "Enable 2FA" on the Security page.
    ...                NOTE: the 2FA setup modal (QR code scan) requires a TOTP app
    ...                and cannot be fully automated without an OTP library.
    Navigate To Security Settings
    Click Element    xpath=//button[normalize-space(text())='Enable 2FA']
    Sleep    2s    # allow Fortify to generate QR code

Two Factor Authentication Is Enabled On Security Page
    [Documentation]    Checks that the "Disable 2FA" button is present, confirming 2FA
    ...                is active for the current user.
    Navigate To Security Settings
    Page Should Contain Element    xpath=//button[normalize-space(text())='Disable 2FA']

Disable Two Factor Authentication
    [Documentation]    Clicks "Disable 2FA" to turn off TOTP for the current account.
    Navigate To Security Settings
    Click Element    xpath=//button[normalize-space(text())='Disable 2FA']
    Sleep    1s
    Page Should Not Contain Element    xpath=//button[normalize-space(text())='Disable 2FA']

# ── Appearance settings ───────────────────────────────────────────────────────

Navigate To Appearance Settings
    [Documentation]    Opens /settings/appearance.
    Navigate To    ${URL_SETTINGS_APPEARANCE}
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}
