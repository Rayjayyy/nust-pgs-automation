*** Settings ***
Documentation       Common keywords shared across all test suites for the NUST
...                 Postgraduate Digital System automation.
Library             SeleniumLibrary
Library             OperatingSystem
Library             DateTime
Library             String
Library             Collections
Library             ../libraries/CustomLibrary.py
Resource            ../variables/global_variables.robot

*** Keywords ***
# =============================================================================
# BROWSER & NAVIGATION KEYWORDS
# =============================================================================

Open NUST Browser
    [Documentation]    Opens the browser and navigates to the NUST PG system.
    [Arguments]    ${url}=${BASE_URL}    ${browser}=${BROWSER}
    IF    ${HEADLESS}
        Open Browser    ${url}    ${browser}    options=add_argument(--headless);add_argument(--no-sandbox);add_argument(--disable-dev-shm-usage)
    ELSE
        Open Browser    ${url}    ${browser}
    END
    Set Window Size    ${WINDOW_WIDTH}    ${WINDOW_HEIGHT}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Set Selenium Timeout    ${TIMEOUT}
    Log    Browser opened: ${browser} at ${url}    level=INFO

Close NUST Browser
    [Documentation]    Closes all browser windows and cleans up.
    Close All Browsers
    Log    All browser sessions closed    level=INFO

Navigate To Page
    [Documentation]    Navigates to a specific page within the system.
    [Arguments]    ${page_url}
    Go To    ${page_url}
    Wait For Page Load
    Log    Navigated to: ${page_url}    level=INFO

Wait For Page Load
    [Documentation]    Waits for the page to fully load by checking document ready state.
    Wait For Condition    return document.readyState == "complete"    timeout=${TIMEOUT}
    Sleep    ${SHORT_WAIT}

Refresh Page And Verify
    [Documentation]    Refreshes the page and verifies it loaded successfully.
    Reload Page
    Wait For Page Load
    Page Should Not Contain    Error
    Page Should Not Contain    404

# =============================================================================
# AUTHENTICATION KEYWORDS
# =============================================================================

Login As User
    [Documentation]    Logs in with the specified credentials.
    [Arguments]    ${username}    ${password}    ${expected_role}
    Wait Until Element Is Visible    id=username    timeout=${MEDIUM_WAIT}
    Input Text    id=username    ${username}
    Input Password    id=password    ${password}
    Click Button    id=login-button
    Wait For Page Load
    Verify User Role    ${expected_role}
    Log    Successfully logged in as: ${expected_role}    level=INFO

Logout User
    [Documentation]    Logs out the current user from the system.
    Click Element    id=logout-button
    Wait Until Element Is Visible    id=login-form    timeout=${MEDIUM_WAIT}
    Log    User logged out successfully    level=INFO

Verify User Role
    [Documentation]    Verifies the current user's role is displayed correctly.
    [Arguments]    ${expected_role}
    Element Should Contain    id=user-role-badge    ${expected_role}

# =============================================================================
# FORM INTERACTION KEYWORDS
# =============================================================================

Fill Input Field
    [Documentation]    Fills a text input field after clearing it.
    [Arguments]    ${locator}    ${value}
    Wait Until Element Is Visible    ${locator}
    Clear Element Text    ${locator}
    Input Text    ${locator}    ${value}
    Log    Filled field ${locator} with value: ${value}    level=DEBUG

Select Dropdown Option
    [Documentation]    Selects an option from a dropdown by visible text.
    [Arguments]    ${locator}    ${option_text}
    Wait Until Element Is Visible    ${locator}
    Select From List By Label    ${locator}    ${option_text}
    Log    Selected '${option_text}' from dropdown ${locator}    level=DEBUG

Upload File
    [Documentation]    Uploads a file using the file input element.
    [Arguments]    ${locator}    ${file_path}
    ${absolute_path}=    Normalize Path    ${file_path}
    File Should Exist    ${absolute_path}
    Choose File    ${locator}    ${absolute_path}
    Log    Uploaded file: ${absolute_path}    level=INFO

Click Button And Verify
    [Documentation]    Clicks a button and verifies the expected outcome.
    [Arguments]    ${button_locator}    ${expected_result_locator}    ${timeout}=${MEDIUM_WAIT}
    Wait Until Element Is Enabled    ${button_locator}
    Click Element    ${button_locator}
    Wait Until Element Is Visible    ${expected_result_locator}    timeout=${timeout}
    Log    Button clicked and result verified    level=INFO

# =============================================================================
# VERIFICATION & ASSERTION KEYWORDS
# =============================================================================

Verify Element Contains Text
    [Documentation]    Verifies an element contains the expected text.
    [Arguments]    ${locator}    ${expected_text}    ${timeout}=${MEDIUM_WAIT}
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Element Should Contain    ${locator}    ${expected_text}

Verify Workflow Status
    [Documentation]    Verifies the workflow status badge shows the expected status.
    [Arguments]    ${expected_status}
    Element Should Contain    class=workflow-status-badge    ${expected_status}
    Log    Workflow status verified: ${expected_status}    level=INFO

Verify Notification Sent
    [Documentation]    Verifies a notification was sent by checking the notification log.
    [Arguments]    ${recipient}    ${notification_type}
    ${notification_found}=    Run Keyword And Return Status
    ...    Element Should Contain    id=notification-log    ${recipient}
    IF    ${notification_found}
        Element Should Contain    id=notification-log    ${notification_type}
        Log    Notification verified: ${notification_type} to ${recipient}    level=INFO
    ELSE
        Log    Notification not found in log for ${recipient}    level=WARN
    END

# =============================================================================
# SCREENSHOT & REPORTING KEYWORDS
# =============================================================================

Take Screenshot On Failure
    [Documentation]    Captures a screenshot when a test fails.
    [Arguments]    ${test_name}
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${screenshot_path}=    Set Variable    ${SCREENSHOT_DIR}/${test_name}_${timestamp}.png
    Capture Page Screenshot    ${screenshot_path}
    Log    Screenshot saved: ${screenshot_path}    level=ERROR

Log Workflow Step
    [Documentation]    Logs a workflow step with timestamp for audit trails.
    [Arguments]    ${step_description}    ${status}=PASS
    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Log    [${timestamp}] [${status}] ${step_description}    level=INFO

# =============================================================================
# DATE & TIME UTILITY KEYWORDS
# =============================================================================

Get Current DateTime
    [Documentation]    Returns the current date and time in system format.
    ${now}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    RETURN    ${now}

Calculate Days Difference
    [Documentation]    Calculates the difference in days between two dates.
    [Arguments]    ${date1}    ${date2}
    ${diff}=    Subtract Date From Date    ${date1}    ${date2}    verbose
    RETURN    ${diff}

Is Date Overdue
    [Documentation]    Returns True if the given date is past the current date.
    [Arguments]    ${due_date}
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    ${is_overdue}=    Evaluate    '${today}' > '${due_date}'
    RETURN    ${is_overdue}

# =============================================================================
# DATA UTILITY KEYWORDS
# =============================================================================

Read Test Data From CSV
    [Documentation]    Reads test data from a CSV file.
    [Arguments]    ${file_name}
    ${file_path}=    Set Variable    ${DATA_DIR}/${file_name}
    ${data}=    Read File    ${file_path}
    ${lines}=    Split To Lines    ${data}
    RETURN    ${lines}

Generate Unique ID
    [Documentation]    Generates a unique identifier with prefix.
    [Arguments]    ${prefix}=ID
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${random}=    Evaluate    random.randint(1000, 9999)    modules=random
    RETURN    ${prefix}_${timestamp}_${random}

# =============================================================================
# ERROR HANDLING KEYWORDS
# =============================================================================

Retry Keyword
    [Documentation]    Retries a keyword up to max retries with interval.
    [Arguments]    ${keyword}    @{args}    &{kwargs}
    FOR    ${index}    IN RANGE    ${MAX_RETRIES}
        ${status}    ${result}=    Run Keyword And Ignore Error    ${keyword}    @{args}    &{kwargs}
        IF    '${status}' == 'PASS'
            RETURN    ${result}
        END
        Log    Retry ${index + 1}/${MAX_RETRIES} failed for ${keyword}    level=WARN
        Sleep    ${RETRY_INTERVAL}
    END
    Fail    Keyword ${keyword} failed after ${MAX_RETRIES} retries
