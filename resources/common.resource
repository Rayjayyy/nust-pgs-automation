*** Settings ***
Documentation    Shared RPA infrastructure keywords for the NUST PGS automation suite.
...
...              This library provides the browser lifecycle, session management,
...              navigation, and assertion primitives used by all role-based bots.
...
...              Tech stack : Laravel 13 + Inertia.js + React (TypeScript)
...              Auth engine : Laravel Fortify
...              Rendering   : Single-Page Application (Inertia SSR disabled)
...
...              LOCATOR NOTES
...              ─────────────
...              All stable locators come from the inspected source code:
...                • Form fields  → HTML id attributes  (id=email, id=password …)
...                • Buttons      → data-test attributes (css=[data-test="…"])
...                • Navigation   → URL location checks after Inertia transitions
...
Library          SeleniumLibrary    timeout=30s    implicit_wait=5s
Library          OperatingSystem
Library          String
Library          DateTime
Library          Collections
Variables        ../variables/config.py

*** Variables ***
${SCREENSHOT_DIR}    ${EXECDIR}/results/screenshots
${DOWNLOADS_DIR}     ${EXECDIR}/results/downloads

*** Keywords ***

# ── Browser lifecycle ─────────────────────────────────────────────────────────

Open PGS Application
    [Documentation]    Creates result folders, opens a Chrome window and loads the
    ...                PGS welcome page (BASE_URL from config.py).
    Create Directory    ${SCREENSHOT_DIR}
    Create Directory    ${DOWNLOADS_DIR}
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    # Wait for Inertia / React to hydrate
    Wait Until Page Contains Element    css=body    timeout=${TIMEOUT}

Close PGS Application
    [Documentation]    Closes all open browser windows.
    Close All Browsers

# ── Authentication ────────────────────────────────────────────────────────────

Login As
    [Documentation]    Fills the Fortify login form (email + password) and submits.
    ...                Waits for the Inertia router to land on /dashboard.
    [Arguments]    ${email}    ${password}
    Go To    ${BASE_URL}${URL_LOGIN}
    # Confirm the login page has loaded (React hydration)
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Clear Element Text    id=email
    Input Text           id=email       ${email}
    Input Text           id=password    ${password}
    Click Element        css=[data-test="login-button"]
    # Inertia SPA: URL changes to /dashboard; wait for it
    Wait Until Location Contains    ${URL_DASHBOARD}    timeout=${TIMEOUT}

Logout
    [Documentation]    Clicks the user-menu logout option (nav-user component) and
    ...                waits for the login page to reappear.
    # NavUser renders a dropdown; the logout form/link is inside it
    Click Element    css=[data-testid="user-menu-trigger"], css=button[aria-label*="user" i], css=[data-test="user-menu"]
    Wait Until Element Is Visible    css=[data-testid="logout-button"], css=button[data-test="logout"], xpath=//button[normalize-space(text())='Log out'] | //a[normalize-space(text())='Log out']    timeout=10s
    Click Element    css=[data-testid="logout-button"], css=button[data-test="logout"], xpath=//button[normalize-space(text())='Log out'] | //a[normalize-space(text())='Log out']
    Wait Until Location Contains    ${URL_LOGIN}    timeout=${TIMEOUT}

# ── Navigation ────────────────────────────────────────────────────────────────

Navigate To
    [Documentation]    Loads an absolute URL path via the browser address bar and
    ...                waits for the React page to settle.
    [Arguments]    ${path}
    Go To    ${BASE_URL}${path}
    Wait Until Element Is Visible    css=main, css=#app, css=body > div    timeout=${TIMEOUT}

Wait For Inertia Navigation
    [Documentation]    After clicking an Inertia link or submitting a form, waits
    ...                until the URL contains the expected path segment.
    [Arguments]    ${expected_path_fragment}
    Wait Until Location Contains    ${expected_path_fragment}    timeout=${TIMEOUT}
    # Also wait for any loading bar to disappear (Inertia progress bar)
    Sleep    0.3s

# ── Assertions ────────────────────────────────────────────────────────────────

Page Should Show Success Toast
    [Documentation]    Waits for a Sonner toast-success notification to appear.
    [Arguments]    ${text}=${EMPTY}
    Wait Until Page Contains Element
    ...    css=[data-sonner-toast][data-type="success"], css=.toast-success, xpath=//*[contains(@class,'sonner') and contains(@data-type,'success')]
    ...    timeout=${TIMEOUT}
    IF    '${text}' != '${EMPTY}'
        Page Should Contain    ${text}
    END

Page Should Show Error Toast
    [Documentation]    Waits for a Sonner toast-error notification to appear.
    [Arguments]    ${text}=${EMPTY}
    Wait Until Page Contains Element
    ...    css=[data-sonner-toast][data-type="error"], css=.toast-error, xpath=//*[contains(@class,'sonner') and contains(@data-type,'error')]
    ...    timeout=${TIMEOUT}
    IF    '${text}' != '${EMPTY}'
        Page Should Contain    ${text}
    END

Field Should Show Validation Error
    [Documentation]    Asserts that a field-level InputError message is visible.
    [Arguments]    ${field_id}
    # InputError renders as a <p> immediately after the field's wrapper
    Wait Until Page Contains Element
    ...    xpath=//input[@id='${field_id}']/following::p[contains(@class,'text-') or @role='alert'][1]
    ...    timeout=10s

# ── Screenshot on failure ──────────────────────────────────────────────────────

Take Timestamped Screenshot
    [Documentation]    Captures a screenshot with a timestamp-suffixed filename.
    [Arguments]    ${label}=failure
    ${ts}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Capture Page Screenshot    ${SCREENSHOT_DIR}/${label}_${ts}.png

# ── Utilities ─────────────────────────────────────────────────────────────────

Get Timestamp
    [Documentation]    Returns the current datetime as a compact string.
    ${ts}=    Get Current Date    result_format=%Y%m%d%H%M%S
    RETURN    ${ts}

Generate Unique Email
    [Documentation]    Returns a unique email address using a timestamp suffix.
    [Arguments]    ${prefix}=testuser
    ${ts}=    Get Timestamp
    RETURN    ${prefix}+${ts}@nust.na
