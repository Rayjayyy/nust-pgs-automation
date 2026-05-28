*** Settings ***
Documentation    Student module test suite.
...
...              Logged-in user : Tendai Moyo (tendai.moyo@students.nust.na)
...              Role           : student  (users.role = 'student')
...              Seed record    : demo-seed.sql id=100
...
...              Business processes automated
...              ────────────────────────────
...              • Submit postgraduate placement application (pg_applications)
...              • Upload Progress Report (progress_reports table – 20 columns)
...              • Upload Table of Changes (submissions, document_versions)
...              • Check individual progress (/my-progress)
...              • Check Supervisor feedback
...              • Check HDC feedback
...
...              NOTE: Business-module routes are not yet in routes/web.php.
...              These tests verify the implemented auth layer and document
...              the expected page behaviour when routes ship.
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/student_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Student Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    student_fail

*** Test Cases ***

Student Lands On Dashboard After Login
    [Documentation]    Tendai Moyo's credentials navigate to /dashboard.
    [Tags]    smoke    student    login
    Student Lands On Dashboard After Login

Dashboard Renders Without Errors
    [Documentation]    The /dashboard page loads without a JS exception.
    ...                Currently shows a placeholder grid (PlaceholderPattern).
    [Tags]    smoke    student    dashboard
    Location Should Contain    ${URL_DASHBOARD}
    Page Should Contain Element    css=main



# ────────────────────────────────────────────────────────────────────────────────
# Progress Report (progress_reports table – 20 template-aligned fields)
# ────────────────────────────────────────────────────────────────────────────────

Student Can Open Progress Report Form
    [Tags]    smoke    student    progress-report    pending
    Navigate To Create Progress Report
    Element Should Be Visible    id=research_title

Student Can Fill And Submit Progress Report
    [Documentation]    Populates all 20 fields from the Progress Report template
    ...                (align_forms_with_templates.php) and submits.
    [Tags]    smoke    student    progress-report    pending
    Navigate To Create Progress Report
    Fill Progress Report Form
    Submit Progress Report

Progress Report Requires Research Title
    [Tags]    regression    student    progress-report    negative    pending
    Navigate To Create Progress Report
    # Leave research_title blank
    Input Text    id=year_under_review    ${PR_YEAR_UNDER_REVIEW}
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    research_title

On Schedule Field Only Accepts Yes Or No
    [Documentation]    on_schedule is a yes/no dropdown; asserts the control exists.
    [Tags]    regression    student    progress-report    pending
    Navigate To Create Progress Report
    Element Should Be Visible    id=on_schedule

# ────────────────────────────────────────────────────────────────────────────────
# Table of Changes
# ────────────────────────────────────────────────────────────────────────────────

Student Can Access Table Of Changes Upload Form
    [Tags]    smoke    student    table-of-changes    pending
    Navigate To Create Table Of Changes
    Element Should Be Visible    css=form

# ────────────────────────────────────────────────────────────────────────────────
# Progress monitoring
# ────────────────────────────────────────────────────────────────────────────────

Student Can View Own Progress Page
    [Tags]    smoke    student    progress    pending
    Navigate To My Progress
    Student Can View Submission History

Student Can View Supervisor Feedback
    [Tags]    smoke    student    feedback    pending
    Navigate To Feedback Page
    Feedback Section Contains Supervisor Comments

Student Can View HDC Feedback
    [Tags]    smoke    student    feedback    hdc    pending
    Navigate To Feedback Page
    Feedback Section Contains HDC Comments

# ────────────────────────────────────────────────────────────────────────────────
# Upload Progress Report Workflow (end-to-end)
# ────────────────────────────────────────────────────────────────────────────────

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