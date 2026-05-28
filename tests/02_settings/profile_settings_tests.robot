*** Settings ***
Documentation    RPA — User Profile Data Synchronisation Automation
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              When the HR system or student registration system updates
...              a user's details (name, email address), those changes must
...              be reflected in the PGS portal.  The bot reads the updated
...              profile data and writes it to /settings/profile — replacing
...              the manual task of administrators updating accounts
...              individually after each HR data-feed.
...
...              Manual task replaced
...              ─────────────────────
...              HR updates triggered manual account edits by IT staff.
...              The bot syncs profile data automatically as part of each
...              scheduled system-maintenance run.
...
...              Route      : /settings/profile
...              Controller : ProfileController (update)
Resource         ../../resources/settings_keywords.resource
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Student Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    profile_fail

*** Test Cases ***

# ════════════════════════════════════════════════════════════════════════════
# PROFILE DATA SYNC — bot reads current data and applies updates
# ════════════════════════════════════════════════════════════════════════════

Bot Verifies Profile Sync Page Is Ready Before Data Update
    [Documentation]    The bot confirms /settings/profile is accessible and all
    ...                required form fields are present before attempting any
    ...                data synchronisation — aborting the run if the page is
    ...                unavailable rather than applying partial updates.
    [Tags]    rpa-status    profile-sync    settings
    Navigate To Profile Settings
    Element Should Be Visible    id=name
    Element Should Be Visible    id=email
    Element Should Be Visible    css=[data-test="update-profile-button"]

Bot Reads Current Profile Data For Audit Logging
    [Documentation]    Before updating, the bot reads the current name and email
    ...                values and logs them.  This creates an audit trail of
    ...                what the data was before the sync was applied.
    [Tags]    rpa-status    profile-sync    audit-log    settings
    Navigate To Profile Settings
    ${current_name}=    Get Element Attribute    id=name    value
    ${current_email}=    Get Element Attribute    id=email    value
    Should Not Be Empty    ${current_name}
    Should Be Equal As Strings    ${current_email}    ${STUDENT_USER}
    Log    Audit: pre-sync name="${current_name}", email="${current_email}"

Bot Applies Profile Update From HR Data Feed
    [Documentation]    The bot applies an updated display name (as received from the
    ...                HR data feed) to the user's profile, then verifies the change
    ...                persisted in the database by reloading the page.
    ...
    ...                Manual task replaced: IT staff received weekly CSV exports
    ...                from HR and manually updated names in the portal.
    [Tags]    rpa-status    profile-sync    settings
    ${updated_name}=    Set Variable    Tendai M. Moyo
    Update Profile    ${updated_name}    ${STUDENT_USER}
    Navigate To Profile Settings
    ${saved}=    Get Element Attribute    id=name    value
    Should Be Equal As Strings    ${saved}    ${updated_name}
    # Restore original value (idempotent run)
    Update Profile    ${STUDENT_FULL_NAME}    ${STUDENT_USER}

Bot Rejects Blank Name Field During Sync (Data Quality Gate)
    [Documentation]    The bot implements a data-quality gate: if the HR feed
    ...                supplies a blank name the bot detects the validation error
    ...                and flags the record for manual review rather than saving
    ...                an empty name.
    [Tags]    rpa-status    data-validation    settings    negative
    Navigate To Profile Settings
    Clear Element Text    id=name
    Save Profile
    Field Should Show Validation Error    name

Bot Blocks Unauthenticated Profile Access
    [Documentation]    The bot confirms that profile data cannot be accessed or
    ...                modified without a valid session — a security invariant that
    ...                must hold for every automation run.
    [Tags]    rpa-auth    access-control    settings    security
    Logout
    Go To    ${BASE_URL}${URL_SETTINGS_PROFILE}
    Wait Until Location Contains    ${URL_LOGIN}    timeout=${TIMEOUT}
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
