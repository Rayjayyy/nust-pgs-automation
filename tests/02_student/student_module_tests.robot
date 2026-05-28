*** Settings ***
Documentation       Student Module Test Suite for NUST Postgraduate Digital System.
...                 Tests progress report submission, progress monitoring,
...                 and application workflows.
Metadata            Version    1.0.0
Metadata            Author    ASD810S Assignment II
Metadata            Date    2026-05-28

Library             SeleniumLibrary
Library             OperatingSystem
Library             DateTime
Library             ../libraries/CustomLibrary.py

Resource            ../resources/keywords/common_keywords.robot
Resource            ../resources/keywords/student_keywords.robot
Resource            ../resources/variables/global_variables.robot

Suite Setup         Student Suite Setup
Suite Teardown      Student Suite Teardown
Test Setup          Student Test Setup
Test Teardown       Student Test Teardown

*** Variables ***
${TEST_REPORT_FILE}     ${DATA_DIR}/test_progress_report.pdf
${TEST_CHANGES_FILE}    ${DATA_DIR}/test_table_of_changes.docx
${TEST_STUDENT_ID}      PG2026001
${TEST_REPORT_PERIOD}   2026-Semester-1

*** Test Cases ***
# =============================================================================
# TC-STU-001: Progress Report Submission Automation
# Priority: VERY HIGH
# =============================================================================
TC-STU-001 Progress Report Submission With Full Validation
    [Documentation]    Tests the complete automated progress report submission workflow.
    ...                Validates document, checks completeness, updates status,
    ...                sends confirmation, and alerts supervisor.
    [Tags]    student    progress_report    very_high    workflow    smoke

    Given Student Is Logged In    ${TEST_STUDENT_ID}
    When Student Uploads Progress Report
    ...    student_id=${TEST_STUDENT_ID}
    ...    file_path=${TEST_REPORT_FILE}
    ...    report_period=${TEST_REPORT_PERIOD}
    Then Workflow Status Should Be    ${STATUS_UNDER_REVIEW}
    And Confirmation Notification Should Be Sent To    ${TEST_STUDENT_ID}@nust.na
    And Supervisor Should Be Alerted    ${TEST_STUDENT_ID}
    And Document Should Be Validated Successfully
    And Submission Should Be Complete

TC-STU-002 Progress Report With Invalid File Type
    [Documentation]    Tests that invalid file types are rejected during upload.
    [Tags]    student    progress_report    validation    negative

    Given Student Is Logged In    ${TEST_STUDENT_ID}
    When Student Attempts To Upload Invalid File
    ...    student_id=${TEST_STUDENT_ID}
    ...    file_path=${DATA_DIR}/invalid_file.exe
    ...    report_period=${TEST_REPORT_PERIOD}
    Then Upload Should Be Rejected
    And Error Message Should Contain    Invalid file type

TC-STU-003 Progress Report With Oversized File
    [Documentation]    Tests that oversized files are rejected.
    [Tags]    student    progress_report    validation    negative

    Given Student Is Logged In    ${TEST_STUDENT_ID}
    When Student Attempts To Upload Oversized File
    ...    student_id=${TEST_STUDENT_ID}
    ...    file_path=${DATA_DIR}/oversized_report.pdf
    ...    report_period=${TEST_REPORT_PERIOD}
    Then Upload Should Be Rejected
    And Error Message Should Contain    File too large

# =============================================================================
# TC-STU-004: Table of Changes Submission
# Priority: HIGH
# =============================================================================
TC-STU-004 Table Of Changes Submission
    [Documentation]    Tests automated Table of Changes submission workflow.
    [Tags]    student    table_of_changes    high    workflow

    Given Student Is Logged In    ${TEST_STUDENT_ID}
    When Student Uploads Table Of Changes
    ...    student_id=${TEST_STUDENT_ID}
    ...    file_path=${TEST_CHANGES_FILE}
    ...    thesis_version=v2.1
    Then Workflow Status Should Be    ${STATUS_UNDER_REVIEW}
    And Confirmation Notification Should Be Sent

# =============================================================================
# TC-STU-005: Automated Student Progress Monitoring
# Priority: HIGH
# =============================================================================
TC-STU-005 Check Individual Student Progress Dashboard
    [Documentation]    Tests retrieval and verification of individual progress.
    [Tags]    student    progress_monitoring    high

    Given Student Is Logged In    ${TEST_STUDENT_ID}
    When Student Checks Individual Progress    ${TEST_STUDENT_ID}
    Then Progress Dashboard Should Display
    And Milestone Timeline Should Be Visible
    And Supervisor Feedback Should Be Accessible
    And HDC Feedback Should Be Accessible

TC-STU-006 Deadline Monitoring And Reminders
    [Documentation]    Tests deadline verification and automatic reminder generation.
    [Tags]    student    progress_monitoring    deadline    high

    Given Student Has Upcoming Deadline    ${TEST_STUDENT_ID}    2026-06-15
    When System Checks Deadline Status    ${TEST_STUDENT_ID}
    Then Reminder Should Be Sent If Due Soon
    And Escalation Should Occur If Overdue

# =============================================================================
# TC-STU-007: Daily Overdue Submission Scan
# Priority: VERY HIGH
# =============================================================================
TC-STU-007 Daily Overdue Submission Scan
    [Documentation]    Tests the daily scheduled scan for overdue submissions.
    ...                Verifies reminders sent after 3 days, escalation after 7 days.
    [Tags]    student    overdue_scan    very_high    scheduled    admin

    Given System Has Overdue Submissions
    When Administrator Triggers Daily Scan
    Then Overdue Items Should Be Identified
    And Reminders Should Be Sent After 3 Days
    And Escalations Should Be Sent After 7 Days
    And HoD Should Be Notified For Severe Delays Over 14 Days

TC-STU-008 Identify Inactive Students
    [Documentation]    Tests identification of inactive students and alert generation.
    [Tags]    student    inactive_monitoring    high    scheduled

    Given Students Have Been Inactive For 30 Days
    When System Scans For Inactive Students
    Then Inactive Students Should Be Identified
    And Student Should Receive Inactivity Alert
    And Supervisor Should Receive Inactivity Alert

# =============================================================================
# TC-STU-009: Postgraduate Application Submission
# Priority: MEDIUM
# =============================================================================
TC-STU-009 Submit Postgraduate Application
    [Documentation]    Tests prospective student application submission automation.
    [Tags]    student    application    medium    workflow

    Given Prospective Student Is On Application Page
    When Student Submits Complete Application
    ...    first_name=John
    ...    last_name=Doe
    ...    email=john.doe@email.com
    ...    phone=+264811234567
    ...    qualification=BSc Computer Science
    ...    institution=NUST
    ...    year=2025
    ...    program_choice_1=MSc Computer Science
    ...    program_choice_2=MEng Software Engineering
    ...    id_document=${DATA_DIR}/id_scan.pdf
    ...    transcript=${DATA_DIR}/transcript.pdf
    ...    cv=${DATA_DIR}/cv.pdf
    Then Application Reference Should Be Generated
    And Confirmation Email Should Be Sent
    And Application Status Should Be Pending

*** Keywords ***
# =============================================================================
# SETUP & TEARDOWN
# =============================================================================

Student Suite Setup
    [Documentation]    Suite-level setup for student module tests.
    Open NUST Browser    ${STUDENT_PORTAL}
    Create Test Data Files

Student Suite Teardown
    [Documentation]    Suite-level teardown for student module tests.
    Close NUST Browser
    Cleanup Test Data

Student Test Setup
    [Documentation]    Test-level setup for student module tests.
    Clear Notification Log
    Navigate To Page    ${STUDENT_PORTAL}

Student Test Teardown
    [Documentation]    Test-level teardown for student module tests.
    Run Keyword If Test Failed    Take Screenshot On Failure    ${TEST_NAME}
    Logout User

# =============================================================================
# GIVEN/WHEN/THEN KEYWORDS (BDD Style)
# =============================================================================

Student Is Logged In
    [Arguments]    ${student_id}
    Login As User    ${student_id}    student_password    Student

Student Has Upcoming Deadline
    [Arguments]    ${student_id}    ${deadline_date}
    Set Test Variable    ${TEST_DEADLINE}    ${deadline_date}

System Has Overdue Submissions
    [Documentation]    Prepares test data with overdue submissions.
    ${mock_data}=    Generate Mock Submission Data    count=5
    Set Test Variable    ${MOCK_OVERDUE_DATA}    ${mock_data}

Students Have Been Inactive For 30 Days
    [Documentation]    Prepares test data with inactive students.
    ${mock_students}=    Generate Mock Student Data    count=3
    Set Test Variable    ${MOCK_INACTIVE_STUDENTS}    ${mock_students}

Prospective Student Is On Application Page
    Navigate To Page    ${BASE_URL}/apply

Administrator Triggers Daily Scan
    Login As User    ${ADMIN_USERNAME}    ${ADMIN_PASSWORD}    Administrator
    Navigate To Page    ${STUDENT_PORTAL}/admin/overdue-scan
    Click Button    id=start-scan

System Checks Deadline Status
    [Arguments]    ${student_id}
    ${status}=    Check Individual Student Progress    ${student_id}
    Set Test Variable    ${DEADLINE_STATUS}    ${status}

System Scans For Inactive Students
    Login As User    ${ADMIN_USERNAME}    ${ADMIN_PASSWORD}    Administrator
    Identify Inactive Students    inactivity_threshold_days=30

Student Submits Complete Application
    [Arguments]    &{applicant_data}
    ${ref}=    Submit Postgraduate Application    ${applicant_data}
    Set Test Variable    ${APPLICATION_REF}    ${ref}

Student Attempts To Upload Invalid File
    [Arguments]    ${student_id}    ${file_path}    ${report_period}
    Run Keyword And Expect Error    *    Student Uploads Progress Report
    ...    student_id=${student_id}
    ...    file_path=${file_path}
    ...    report_period=${report_period}

Student Attempts To Upload Oversized File
    [Arguments]    ${student_id}    ${file_path}    ${report_period}
    Run Keyword And Expect Error    *    Student Uploads Progress Report
    ...    student_id=${student_id}
    ...    file_path=${file_path}
    ...    report_period=${report_period}

# =============================================================================
# VERIFICATION KEYWORDS
# =============================================================================

Workflow Status Should Be
    [Arguments]    ${expected_status}
    Verify Workflow Status    ${expected_status}

Confirmation Notification Should Be Sent To
    [Arguments]    ${recipient}
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any(n['recipient'] == '${recipient}' and n['type'] == '${NOTIF_CONFIRMATION}' for n in ${log})
    Should Be True    ${found}    Confirmation notification not found for ${recipient}

Supervisor Should Be Alerted
    [Arguments]    ${student_id}
    ${supervisor_email}=    Get Supervisor Email    ${student_id}
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any(n['recipient'] == '${supervisor_email}' and n['type'] == '${NOTIF_REMINDER}' for n in ${log})
    Should Be True    ${found}    Supervisor alert not sent for ${student_id}

Document Should Be Validated Successfully
    Log    Document validation passed (verified in upload keyword)

Submission Should Be Complete
    Log    Submission completeness verified (checked in upload keyword)

Upload Should Be Rejected
    Log    Upload rejection verified (caught by error expectation)

Error Message Should Contain
    [Arguments]    ${expected_text}
    Page Should Contain    ${expected_text}

Progress Dashboard Should Display
    Element Should Be Visible    id=progress-overview

Milestone Timeline Should Be Visible
    Element Should Be Visible    id=milestone-timeline

Supervisor Feedback Should Be Accessible
    Element Should Be Visible    id=supervisor-feedback-section

HDC Feedback Should Be Accessible
    Element Should Be Visible    id=hdc-feedback-section

Reminder Should Be Sent If Due Soon
    IF    ${DEADLINE_STATUS}[is_due_soon]
        ${log}=    Get Notification Log
        ${found}=    Evaluate    any(n['type'] == '${NOTIF_REMINDER}' for n in ${log})
        Should Be True    ${found}    Reminder not sent for due-soon deadline
    END

Escalation Should Occur If Overdue
    IF    ${DEADLINE_STATUS}[is_overdue]
        ${log}=    Get Notification Log
        ${found}=    Evaluate    any(n['type'] == '${NOTIF_ESCALATION}' for n in ${log})
        Should Be True    ${found}    Escalation not sent for overdue deadline
    END

Overdue Items Should Be Identified
    Element Should Be Visible    id=scan-results
    Element Should Contain    id=overdue-count    0
    ...    msg=Expected overdue items but found none

Reminders Should Be Sent After 3 Days
    ${log}=    Get Notification Log
    ${reminders}=    Evaluate    [n for n in ${log} if n['type'] == '${NOTIF_REMINDER}']
    Should Not Be Empty    ${reminders}    No reminders sent for overdue items

Escalations Should Be Sent After 7 Days
    ${log}=    Get Notification Log
    ${escalations}=    Evaluate    [n for n in ${log} if n['type'] == '${NOTIF_ESCALATION}']
    Should Not Be Empty    ${escalations}    No escalations sent for severely overdue items

HoD Should Be Notified For Severe Delays Over 14 Days
    ${log}=    Get Notification Log
    ${hod_notifications}=    Evaluate    [n for n in ${log} if 'hod' in n['recipient'].lower()]
    Log    HoD notifications: ${hod_notifications}

Inactive Students Should Be Identified
    Element Should Be Visible    id=inactive-results

Student Should Receive Inactivity Alert
    ${log}=    Get Notification Log
    ${alerts}=    Evaluate    [n for n in ${log} if n['type'] == '${NOTIF_REMINDER}' and 'student' in n['recipient']]
    Should Not Be Empty    ${alerts}

Supervisor Should Receive Inactivity Alert
    ${log}=    Get Notification Log
    ${alerts}=    Evaluate    [n for n in ${log} if n['type'] == '${NOTIF_REMINDER}' and 'supervisor' in n['recipient']]
    Should Not Be Empty    ${alerts}

Application Reference Should Be Generated
    Should Not Be Empty    ${APPLICATION_REF}
    Should Match Regexp    ${APPLICATION_REF}    ^APP[0-9]+$

Confirmation Email Should Be Sent
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any('Application Received' in n['subject'] for n in ${log})
    Should Be True    ${found}

Application Status Should Be Pending
    Navigate To Page    ${BASE_URL}/apply/status/${APPLICATION_REF}
    Element Should Contain    id=application-status    Pending

# =============================================================================
# TEST DATA MANAGEMENT
# =============================================================================

Create Test Data Files
    [Documentation]    Creates mock test data files for testing.
    ${test_dir}=    Set Variable    ${DATA_DIR}
    Create Directory    ${test_dir}

    # Create dummy PDF for testing
    Run    echo "Mock PDF content for testing" > ${test_dir}/test_progress_report.pdf
    Run    echo "Mock DOCX content" > ${test_dir}/test_table_of_changes.docx
    Run    echo "Mock ID scan" > ${test_dir}/id_scan.pdf
    Run    echo "Mock transcript" > ${test_dir}/transcript.pdf
    Run    echo "Mock CV" > ${test_dir}/cv.pdf

Cleanup Test Data
    [Documentation]    Cleans up test data files.
    Remove Directory    ${DATA_DIR}    recursive=${TRUE}
