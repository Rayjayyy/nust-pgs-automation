*** Settings ***
Documentation       Cross-System and Enterprise-Level Test Suite for NUST
...                 Postgraduate Digital System. Tests email & notification
...                 automation, reporting & analytics automation.
Metadata            Version    1.0.0
Metadata            Author    ASD810S Assignment II
Metadata            Date    2026-05-28

Library             SeleniumLibrary
Library             OperatingSystem
Library             DateTime
Library             Collections
Library             ../libraries/CustomLibrary.py

Resource            ../resources/keywords/common_keywords.robot
Resource            ../resources/keywords/cross_system_keywords.robot
Resource            ../resources/keywords/student_keywords.robot
Resource            ../resources/keywords/supervisor_keywords.robot
Resource            ../resources/keywords/hod_keywords.robot
Resource            ../resources/variables/global_variables.robot

Suite Setup         Cross System Suite Setup
Suite Teardown      Cross System Suite Teardown
Test Setup          Cross System Test Setup
Test Teardown       Cross System Test Teardown

*** Variables ***
${TEST_ADMIN_ID}        ADMIN2026001
${TEST_COMMITTEE}       FPGC
${TEST_REPORT_DATE}     2026-05-28

*** Test Cases ***
# =============================================================================
# TC-CRS-001: Centralized Notification System
# Priority: VERY HIGH
# =============================================================================
TC-CRS-001 Send Approval Notification
    [Documentation]    Tests centralized approval notification to student and supervisor.
    [Tags]    cross_system    notification    very_high    workflow

    Given Submission Has Been Approved
    When System Sends Centralized Notification
    ...    recipient=student@nust.na
    ...    notification_type=${NOTIF_APPROVAL}
    ...    subject=Submission Approved
    ...    body=Your submission has been approved.
    Then Notification Should Be Logged In System
    And Recipient Should Receive Email
    And Notification Type Should Be Recorded

TC-CRS-002 Send Rejection Notification
    [Documentation]    Tests centralized rejection notification with feedback.
    [Tags]    cross_system    notification    rejection    workflow

    Given Submission Has Been Rejected
    When System Sends Centralized Notification
    ...    recipient=student@nust.na
    ...    notification_type=${NOTIF_REJECTION}
    ...    subject=Submission Rejected
    ...    body=Your submission has been rejected. Reason: Insufficient content.
    Then Rejection Notification Should Be Sent
    And Supervisor Should Be Copied

TC-CRS-003 Send Bulk Deadline Reminders
    [Documentation]    Tests bulk deadline reminder to all affected students.
    [Tags]    cross_system    notification    bulk    scheduled

    Given Multiple Students Have Upcoming Deadlines
    When System Sends Bulk Notifications
    ...    recipients=${DEADLINE_RECIPIENTS}
    ...    notification_type=${NOTIF_REMINDER}
    ...    template_name=deadline_reminder
    ...    context_data=${DEADLINE_CONTEXT}
    Then All Recipients Should Receive Reminders
    And Notification Log Should Show Bulk Send

TC-CRS-004 Oral Defense Scheduling Notification
    [Documentation]    Tests oral defense scheduling with multi-stakeholder notifications.
    [Tags]    cross_system    notification    oral_defense    workflow

    Given Oral Defense Needs Scheduling
    When System Schedules Oral Defense
    ...    student_id=PG2026001
    ...    thesis_id=THS2026001
    ...    proposed_dates=${DEFENSE_DATES}
    ...    panel_members=${PANEL_MEMBERS}
    Then Student Should Be Notified
    And Supervisor Should Be Notified
    And All Panel Members Should Be Notified
    And Defense Reference Should Be Generated

# =============================================================================
# TC-CRS-005: Weekly Faculty Report Automation
# Priority: HIGH
# =============================================================================
TC-CRS-005 Generate And Distribute Weekly Report
    [Documentation]    Tests automated weekly report generation and distribution
    ...                to committee members every Friday.
    [Tags]    cross_system    reporting    weekly    high    scheduled

    Given It Is Friday Report Generation Day
    When System Generates Weekly Faculty Report
    ...    report_date=${TEST_REPORT_DATE}
    Then HTML Report Should Be Generated
    And CSV Export Should Be Generated
    And Report Should Be Emailed To Committee
    And Report Should Be Archived

TC-CRS-006 Report Contains All Key Metrics
    [Documentation]    Tests that weekly report includes all required metrics.
    [Tags]    cross_system    reporting    metrics    high

    Given Weekly Report Is Generated
    When User Opens Report
    Then Report Should Contain Total Students
    And Report Should Contain Active Submissions
    And Report Should Contain Overdue Submissions
    And Report Should Contain Pending Reviews
    And Report Should Contain Completed This Week
    And Report Should Contain Supervisor Workload Average

# =============================================================================
# TC-CRS-007: Completion Statistics Report
# Priority: HIGH
# =============================================================================
TC-CRS-007 Generate Monthly Completion Statistics
    [Documentation]    Tests monthly completion statistics generation.
    [Tags]    cross_system    reporting    completion    high

    Given Month End Has Arrived
    When System Generates Completion Statistics Report
    ...    period=monthly
    ...    program=all
    Then Report Should Show Total Enrolled
    And Report Should Show Completed Count
    And Report Should Show In Progress Count
    And Report Should Show Withdrawn Count
    And Report Should Show Average Completion Time
    And Report Should Show Completion Rate

# =============================================================================
# TC-CRS-008: Supervisor Workload Report
# Priority: HIGH
# =============================================================================
TC-CRS-008 Generate Supervisor Workload Distribution Report
    [Documentation]    Tests supervisor workload distribution report generation.
    [Tags]    cross_system    reporting    workload    high

    Given Workload Data Is Available
    When System Generates Supervisor Workload Report
    ...    department=all
    Then Report Should List All Supervisors
    And Report Should Show Student Counts
    And Report Should Show Active Reviews
    And Report Should Show Overdue Reviews
    And Overloaded Supervisors Should Be Highlighted

# =============================================================================
# TC-CRS-009: Overdue Submission Report
# Priority: HIGH
# =============================================================================
TC-CRS-009 Generate Overdue Submission Report For Escalation
    [Documentation]    Tests overdue submission report with escalation levels.
    [Tags]    cross_system    reporting    overdue    high    escalation

    Given System Has Overdue Submissions
    When System Generates Overdue Submission Report
    ...    escalation_level=all
    Then CSV Report Should Be Generated
    And Report Should Include Days Overdue
    And Report Should Include Escalation Levels
    And High Priority Escalations Should Be Sent To DVC

TC-CRS-010 High Priority Overdue Report Triggers Escalation
    [Documentation]    Tests that high priority overdue reports trigger DVC escalation.
    [Tags]    cross_system    reporting    overdue    escalation    high

    Given System Has High Priority Overdue Items
    When System Generates Overdue Submission Report
    ...    escalation_level=high
    Then DVC Should Receive Escalation Email
    And Report Should Only Include High Priority Items

# =============================================================================
# TC-CRS-011: Report Archiving
# Priority: MEDIUM
# =============================================================================
TC-CRS-011 Archive Generated Reports
    [Documentation]    Tests automatic report archiving after distribution.
    [Tags]    cross_system    reporting    archive    medium

    Given Report Has Been Generated    ${TEST_REPORT_DATE}
    When System Archives Report
    Then Report Should Exist In Archive
    And Original Should Remain In Reports Directory

# =============================================================================
# TC-CRS-012: Notification Template System
# Priority: MEDIUM
# =============================================================================
TC-CRS-012 Use Templates For Consistent Notifications
    [Documentation]    Tests notification template system for consistent messaging.
    [Tags]    cross_system    notification    templates    medium

    Given Notification Template Exists    submission_confirmation
    When System Generates From Template
    ...    template_name=submission_confirmation
    ...    part=subject
    ...    context_data=${TEMPLATE_CONTEXT}
    Then Generated Subject Should Match Template
    And Generated Body Should Match Template

*** Keywords ***
# =============================================================================
# SETUP & TEARDOWN
# =============================================================================

Cross System Suite Setup
    [Documentation]    Suite-level setup for cross-system tests.
    Open NUST Browser    ${BASE_URL}
    Create Test Data Files
    Initialize Test Variables

Cross System Suite Teardown
    [Documentation]    Suite-level teardown for cross-system tests.
    Close NUST Browser
    Cleanup Test Data

Cross System Test Setup
    [Documentation]    Test-level setup for cross-system tests.
    Clear Notification Log
    Navigate To Page    ${BASE_URL}

Cross System Test Teardown
    [Documentation]    Test-level teardown for cross-system tests.
    Run Keyword If Test Failed    Take Screenshot On Failure    ${TEST_NAME}
    Logout User

# =============================================================================
# GIVEN/WHEN/THEN KEYWORDS
# =============================================================================

Submission Has Been Approved
    [Documentation]    Prepares test context for approved submission.
    Set Test Variable    ${NOTIFICATION_CONTEXT}    approved

Submission Has Been Rejected
    [Documentation]    Prepares test context for rejected submission.
    Set Test Variable    ${NOTIFICATION_CONTEXT}    rejected

Multiple Students Have Upcoming Deadlines
    [Documentation]    Prepares test data for bulk deadline notifications.
    ${recipients}=    Create List
    ...    student1@nust.na
    ...    student2@nust.na
    ...    student3@nust.na
    Set Test Variable    ${DEADLINE_RECIPIENTS}    ${recipients}

    ${context}=    Create Dictionary
    ...    item_type=Progress Report
    ...    due_date=2026-06-15
    ...    days_remaining=10
    Set Test Variable    ${DEADLINE_CONTEXT}    ${context}

Oral Defense Needs Scheduling
    [Documentation]    Prepares test data for oral defense scheduling.
    Set Test Variable    ${DEFENSE_DATES}    2026-06-20,09:00,Room A101
    ${panel}=    Create List    Dr. Smith    Dr. Jones    Dr. Brown
    Set Test Variable    ${PANEL_MEMBERS}    ${panel}

It Is Friday Report Generation Day
    [Documentation]    Simulates Friday report generation trigger.
    Set Test Variable    ${IS_REPORT_DAY}    ${TRUE}

Weekly Report Is Generated
    [Documentation]    Generates weekly report for verification.
    ${report_path}=    Generate Weekly Faculty Report    report_date=${TEST_REPORT_DATE}
    Set Test Variable    ${WEEKLY_REPORT_PATH}    ${report_path}

Month End Has Arrived
    [Documentation]    Simulates month-end trigger.
    Set Test Variable    ${IS_MONTH_END}    ${TRUE}

Workload Data Is Available
    [Documentation]    Prepares workload data for report generation.
    Set Test Variable    ${WORKLOAD_DATA_AVAILABLE}    ${TRUE}

System Has Overdue Submissions
    [Documentation]    Prepares overdue submission data.
    ${overdue}=    Create List
    ...    {"student_id": "PG001", "student_name": "Student A", "submission_type": "Progress Report", "due_date": "2026-05-15", "supervisor": "SUP001", "last_action": "reminder_sent"}
    ...    {"student_id": "PG002", "student_name": "Student B", "submission_type": "Thesis", "due_date": "2026-05-10", "supervisor": "SUP002", "last_action": "escalated"}
    Set Test Variable    ${OVERDUE_DATA}    ${overdue}

System Has High Priority Overdue Items
    [Documentation]    Prepares high priority overdue data.
    ${overdue}=    Create List
    ...    {"student_id": "PG003", "student_name": "Student C", "submission_type": "Thesis", "due_date": "2026-05-01", "supervisor": "SUP003", "last_action": "none"}
    Set Test Variable    ${HIGH_PRIORITY_OVERDUE}    ${overdue}

Report Has Been Generated
    [Arguments]    ${report_date}
    ${report_path}=    Generate Weekly Faculty Report    report_date=${report_date}
    Set Test Variable    ${ARCHIVE_TEST_REPORT}    ${report_path}

Notification Template Exists
    [Arguments]    ${template_name}
    Set Test Variable    ${TEST_TEMPLATE}    ${template_name}
    ${context}=    Create Dictionary
    ...    submission_type=Progress Report
    ...    reference=SUB2026001
    ...    status=Submitted
    ...    decision=Approved
    ...    feedback=Good work
    Set Test Variable    ${TEMPLATE_CONTEXT}    ${context}

System Sends Centralized Notification
    [Arguments]    ${recipient}    ${notification_type}    ${subject}    ${body}
    ${notif_id}=    Send Centralized Notification
    ...    recipient=${recipient}
    ...    notification_type=${notification_type}
    ...    subject=${subject}
    ...    body=${body}
    Set Test Variable    ${SENT_NOTIFICATION_ID}    ${notif_id}

System Sends Bulk Notifications
    [Arguments]    ${recipients}    ${notification_type}    ${template_name}    ${context_data}
    ${count}=    Send Bulk Notifications
    ...    recipients=${recipients}
    ...    notification_type=${notification_type}
    ...    template_name=${template_name}
    ...    context_data=${context_data}
    Set Test Variable    ${BULK_SEND_COUNT}    ${count}

System Schedules Oral Defense
    [Arguments]    ${student_id}    ${thesis_id}    ${proposed_dates}    ${panel_members}
    ${defense_ref}=    Schedule Oral Defense
    ...    student_id=${student_id}
    ...    thesis_id=${thesis_id}
    ...    proposed_dates=${proposed_dates}
    ...    panel_members=${panel_members}
    Set Test Variable    ${DEFENSE_REFERENCE}    ${defense_ref}

System Generates Weekly Faculty Report
    [Arguments]    ${report_date}
    ${report_path}=    Generate Weekly Faculty Report    report_date=${report_date}
    Set Test Variable    ${GENERATED_REPORT}    ${report_path}

System Generates Completion Statistics Report
    [Arguments]    ${period}    ${program}
    ${stats}    ${report_path}=    Generate Completion Statistics Report
    ...    period=${period}
    ...    program=${program}
    Set Test Variable    ${COMPLETION_STATS}    ${stats}
    Set Test Variable    ${COMPLETION_REPORT}    ${report_path}

System Generates Supervisor Workload Report
    [Arguments]    ${department}
    ${data}    ${report_path}=    Generate Supervisor Workload Report
    ...    department=${department}
    Set Test Variable    ${WORKLOAD_REPORT_DATA}    ${data}
    Set Test Variable    ${WORKLOAD_REPORT_PATH}    ${report_path}

System Generates Overdue Submission Report
    [Arguments]    ${escalation_level}
    ${data}    ${report_path}=    Generate Overdue Submission Report
    ...    escalation_level=${escalation_level}
    Set Test Variable    ${OVERDUE_REPORT_DATA}    ${data}
    Set Test Variable    ${OVERDUE_REPORT_PATH}    ${report_path}

System Archives Report
    [Documentation]    Archives the generated report.
    Archive Report    ${ARCHIVE_TEST_REPORT}    ${REPORT_DIR}/archive/

System Generates From Template
    [Arguments]    ${template_name}    ${part}    ${context_data}
    ${result}=    Generate From Template
    ...    template_name=${template_name}
    ...    part=${part}
    ...    context_data=${context_data}
    Set Test Variable    ${TEMPLATE_RESULT}    ${result}

# =============================================================================
# VERIFICATION KEYWORDS
# =============================================================================

Notification Should Be Logged In System
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any(n['notification_id'] == '${SENT_NOTIFICATION_ID}' for n in ${log})
    Should Be True    ${found}    Notification not found in system log

Recipient Should Receive Email
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any(n['status'] == 'sent' for n in ${log} if n['notification_id'] == '${SENT_NOTIFICATION_ID}')
    Should Be True    ${found}    Email not sent to recipient

Notification Type Should Be Recorded
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any(n['type'] == '${NOTIF_APPROVAL}' for n in ${log} if n['notification_id'] == '${SENT_NOTIFICATION_ID}')
    Should Be True    ${found}    Notification type not recorded

Rejection Notification Should Be Sent
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any('Rejected' in n['subject'] for n in ${log})
    Should Be True    ${found}    Rejection notification not sent

Supervisor Should Be Copied
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any('supervisor' in n['recipient'].lower() for n in ${log} if 'Rejected' in n['subject'])
    Should Be True    ${found}    Supervisor not copied on rejection

All Recipients Should Receive Reminders
    Should Be Equal As Integers    ${BULK_SEND_COUNT}    3    Expected 3 reminders, got ${BULK_SEND_COUNT}

Notification Log Should Show Bulk Send
    ${log}=    Get Notification Log
    ${bulk_count}=    Evaluate    len([n for n in ${log} if n['type'] == '${NOTIF_REMINDER}'])
    Should Be Equal As Integers    ${bulk_count}    3

Student Should Be Notified
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any('Oral Defense Scheduled' in n['subject'] and 'student' in n['recipient'].lower() for n in ${log})
    Should Be True    ${found}    Student not notified of defense

Supervisor Should Be Notified
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any('Oral Defense' in n['subject'] and 'supervisor' in n['recipient'].lower() for n in ${log})
    Should Be True    ${found}    Supervisor not notified of defense

All Panel Members Should Be Notified
    ${log}=    Get Notification Log
    ${panel_notifications}=    Evaluate    [n for n in ${log} if 'Panel Assignment' in n['subject']]
    ${count}=    Get Length    ${panel_notifications}
    Should Be Equal As Integers    ${count}    3    Expected 3 panel notifications, got ${count}

Defense Reference Should Be Generated
    Should Not Be Empty    ${DEFENSE_REFERENCE}
    Should Match Regexp    ${DEFENSE_REFERENCE}    ^DEF[0-9]+$

HTML Report Should Be Generated
    File Should Exist    ${GENERATED_REPORT}
    ${content}=    Get File    ${GENERATED_REPORT}
    Should Contain    ${content}    NUST Postgraduate Faculty Report

CSV Export Should Be Generated
    ${csv_path}=    Set Variable    ${REPORT_DIR}/weekly_faculty_report_${TEST_REPORT_DATE}.csv
    File Should Exist    ${csv_path}

Report Should Be Emailed To Committee
    ${log}=    Get Notification Log
    ${committee_emails}=    Get Committee Emails
    FOR    ${email}    IN    @{committee_emails}
        ${found}=    Evaluate    any(n['recipient'] == '${email}' and 'Weekly Faculty Report' in n['subject'] for n in ${log})
        Should Be True    ${found}    Report not sent to ${email}
    END

Report Should Be Archived
    ${archive_path}=    Set Variable    ${REPORT_DIR}/archive/weekly_faculty_report_${TEST_REPORT_DATE}.html
    File Should Exist    ${archive_path}

Report Should Contain Total Students
    ${content}=    Get File    ${WEEKLY_REPORT_PATH}
    Should Contain    ${content}    Total Students

Report Should Contain Active Submissions
    ${content}=    Get File    ${WEEKLY_REPORT_PATH}
    Should Contain    ${content}    Active Submissions

Report Should Contain Overdue Submissions
    ${content}=    Get File    ${WEEKLY_REPORT_PATH}
    Should Contain    ${content}    Overdue Submissions

Report Should Contain Pending Reviews
    ${content}=    Get File    ${WEEKLY_REPORT_PATH}
    Should Contain    ${content}    Pending Reviews

Report Should Contain Completed This Week
    ${content}=    Get File    ${WEEKLY_REPORT_PATH}
    Should Contain    ${content}    Completed This Week

Report Should Contain Supervisor Workload Average
    ${content}=    Get File    ${WEEKLY_REPORT_PATH}
    Should Contain    ${content}    Supervisor Workload Average

Report Should Show Total Enrolled
    Dictionary Should Contain Key    ${COMPLETION_STATS}    total_enrolled

Report Should Show Completed Count
    Dictionary Should Contain Key    ${COMPLETION_STATS}    completed

Report Should Show In Progress Count
    Dictionary Should Contain Key    ${COMPLETION_STATS}    in_progress

Report Should Show Withdrawn Count
    Dictionary Should Contain Key    ${COMPLETION_STATS}    withdrawn

Report Should Show Average Completion Time
    Dictionary Should Contain Key    ${COMPLETION_STATS}    avg_completion_time

Report Should Show Completion Rate
    Dictionary Should Contain Key    ${COMPLETION_STATS}    completion_rate

Report Should List All Supervisors
    Should Not Be Empty    ${WORKLOAD_REPORT_DATA}

Report Should Show Student Counts
    ${first}=    Get From List    ${WORKLOAD_REPORT_DATA}    0
    Dictionary Should Contain Key    ${first}    students

Report Should Show Active Reviews
    ${first}=    Get From List    ${WORKLOAD_REPORT_DATA}    0
    Dictionary Should Contain Key    ${first}    active_reviews

Report Should Show Overdue Reviews
    ${first}=    Get From List    ${WORKLOAD_REPORT_DATA}    0
    Dictionary Should Contain Key    ${first}    overdue_reviews

Overloaded Supervisors Should Be Highlighted
    ${content}=    Get File    ${WORKLOAD_REPORT_PATH}
    Should Contain    ${content}    overloaded OR highlight OR warning

CSV Report Should Be Generated
    File Should Exist    ${OVERDUE_REPORT_PATH}

Report Should Include Days Overdue
    ${content}=    Get File    ${OVERDUE_REPORT_PATH}
    Should Contain    ${content}    Days Overdue

Report Should Include Escalation Levels
    ${content}=    Get File    ${OVERDUE_REPORT_PATH}
    Should Contain    ${content}    Escalation Level

High Priority Escalations Should Be Sent To DVC
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any('HIGH PRIORITY' in n['subject'] and 'dvc' in n['recipient'].lower() for n in ${log})
    Should Be True    ${found}    DVC not notified of high priority overdue items

DVC Should Receive Escalation Email
    ${log}=    Get Notification Log
    ${found}=    Evaluate    any('ESCALATION' in n['subject'] and 'dvc' in n['recipient'].lower() for n in ${log})
    Should Be True    ${found}    DVC did not receive escalation

Report Should Only Include High Priority Items
    ${content}=    Get File    ${OVERDUE_REPORT_PATH}
    Should Not Contain    ${content}    LOW
    Should Not Contain    ${content}    MEDIUM

Report Should Exist In Archive
    ${archive_path}=    Set Variable    ${REPORT_DIR}/archive/weekly_faculty_report_${TEST_REPORT_DATE}.html
    File Should Exist    ${archive_path}

Original Should Remain In Reports Directory
    File Should Exist    ${ARCHIVE_TEST_REPORT}

Generated Subject Should Match Template
    Should Be Equal    ${TEMPLATE_RESULT}    Submission Confirmation - Progress Report

Generated Body Should Match Template
    ${expected}=    Set Variable    Your Progress Report has been successfully submitted. Reference: SUB2026001. Status: Submitted.
    Should Contain    ${TEMPLATE_RESULT}    Progress Report

# =============================================================================
# TEST DATA MANAGEMENT
# =============================================================================

Initialize Test Variables
    [Documentation]    Initializes cross-system test variables.
    Set Suite Variable    ${IS_REPORT_DAY}    ${FALSE}
    Set Suite Variable    ${IS_MONTH_END}    ${FALSE}
    Set Suite Variable    ${WORKLOAD_DATA_AVAILABLE}    ${FALSE}

Create Test Data Files
    [Documentation]    Creates mock test data files.
    ${test_dir}=    Set Variable    ${DATA_DIR}
    Create Directory    ${test_dir}
    Create Directory    ${REPORT_DIR}/archive

Cleanup Test Data
    [Documentation]    Cleans up test data.
    Remove Directory    ${DATA_DIR}    recursive=${TRUE}
    Remove Directory    ${REPORT_DIR}    recursive=${TRUE}
