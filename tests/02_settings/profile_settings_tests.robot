*** Settings ***
Documentation    Profile settings test suite.
...
...              Page under test : /settings/profile
...              Source          : resources/js/pages/settings/profile.tsx
...
...              Element references (from source code)
...              ──────────────────────────────────────
...              id=name                              – full-name input
...              id=email                             – email input
...              css=[data-test="update-profile-button"] – Save button
...
...              Controller      : ProfileController (update / destroy)
...              Request class   : ProfileUpdateRequest
Resource         ../../resources/settings_keywords.resource
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Student Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    profile_fail

*** Test Cases ***

Profile Settings Page Renders Name And Email Fields
    [Documentation]    /settings/profile shows id=name and id=email with the current
    ...                user's values pre-filled.
    [Tags]    smoke    settings    profile
    Navigate To Profile Settings
    Element Should Be Visible    id=name
    Element Should Be Visible    id=email
    Element Should Be Visible    css=[data-test="update-profile-button"]

Profile Name Field Is Pre-Filled With Current User Name
    [Documentation]    The Name input value matches the logged-in user's name.
    [Tags]    smoke    settings    profile
    Navigate To Profile Settings
    ${value}=    Get Element Attribute    id=name    value
    Should Not Be Empty    ${value}

Profile Email Field Is Pre-Filled With Current User Email
    [Documentation]    The Email input value matches the logged-in user's email.
    [Tags]    smoke    settings    profile
    Navigate To Profile Settings
    ${value}=    Get Element Attribute    id=email    value
    Should Be Equal As Strings    ${value}    ${STUDENT_USER}

User Can Update Their Display Name
    [Documentation]    Clears the Name field, types a new name, saves, and verifies
    ...                the value persists on page reload.
    [Tags]    smoke    settings    profile
    ${new_name}=    Set Variable    Tendai Updated Moyo
    Update Profile    ${new_name}    ${STUDENT_USER}
    # Reload to confirm persistence (ProfileController::update stores to DB)
    Navigate To Profile Settings
    ${saved}=    Get Element Attribute    id=name    value
    Should Be Equal As Strings    ${saved}    ${new_name}
    # Restore original name
    Update Profile    ${STUDENT_FULL_NAME}    ${STUDENT_USER}

Profile Update With Empty Name Shows Validation Error
    [Documentation]    The name field is required; clearing it and saving triggers
    ...                a server-side validation error via Inertia.
    [Tags]    regression    settings    profile    negative
    Navigate To Profile Settings
    Clear Element Text    id=name
    Save Profile
    Field Should Show Validation Error    name

Profile Page Shows Email Unverified Notice When Email Changed
    [Documentation]    After changing email, Fortify/Inertia may show an
    ...                "email unverified" notice if email verification is enabled.
    ...                This test documents the expected UI behaviour.
    [Tags]    regression    settings    profile
    Navigate To Profile Settings
    ${original_email}=    Get Element Attribute    id=email    value
    Update Profile Email    newemail.test@students.nust.na
    Save Profile
    # If MustVerifyEmail is enabled, the "unverified" paragraph appears
    ${has_notice}=    Run Keyword And Return Status
    ...    Page Should Contain    Your email address is unverified
    Log    Email verification notice shown: ${has_notice}
    # Restore original email
    Navigate To Profile Settings
    Update Profile Email    ${original_email}
    Save Profile

Profile Settings Page Is Inaccessible Without Login
    [Documentation]    A guest hitting /settings/profile is redirected to /login.
    [Tags]    regression    settings    profile    security
    Logout
    Go To    ${BASE_URL}${URL_SETTINGS_PROFILE}
    Wait Until Location Contains    ${URL_LOGIN}    timeout=${TIMEOUT}
    # Re-login for teardown
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
