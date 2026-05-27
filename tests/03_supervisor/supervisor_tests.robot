*** Settings ***
Documentation    Supervisor module test suite.
...
...              Logged-in user : Prof. James Chikwanha (j.chikwanha@nust.na)
...              Role           : supervisor  (users.role = 'supervisor')
...              Seed record    : demo-seed.sql id=101
...
...              Business processes automated
...              ────────────────────────────
...              • Submit Summary of Proposals (SoP) to HoD
...              • Submit thesis to HoD
...              • Comment and sign student Progress Report
...              • Grade student's final thesis
...              • Monitor student progress
...
...              Database tables exercised
...              ─────────────────────────
...              summary_of_proposals, supervisor_reviews, thesis_evaluations
...
...              NOTE: The business-module routes (/submissions/*, /progress-reports/*)
...              are not yet registered in routes/web.php.  Tests are marked
...              [Tags] pending and will be activated when the routes ship.
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/supervisor_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Supervisor Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    supervisor_fail

*** Test Cases ***

Supervisor Lands On Dashboard After Login
    [Documentation]    Prof. Chikwanha's credentials navigate to /dashboard.
    [Tags]    smoke    supervisor    login
    Location Should Contain    ${URL_DASHBOARD}

# ────────────────────────────────────────────────────────────────────────────────
# Summary of Proposals
# ────────────────────────────────────────────────────────────────────────────────

Supervisor Can Open SoP Creation Form
    [Documentation]    The SoP form page is reachable and shows the thesis_type field.
    [Tags]    smoke    supervisor    sop    pending
    Navigate To Create SoP
    Element Should Be Visible    id=thesis_type

Supervisor Can Fill And Submit Summary Of Proposals
    [Documentation]    All 15 template fields from summary_of_proposals table are
    ...                populated and the form submitted to HoD.
    [Tags]    smoke    supervisor    sop    pending
    Navigate To Create SoP
    Fill Summary Of Proposals Form
    Submit SoP To HoD

Supervisor Cannot Submit SoP Without Thesis Type
    [Documentation]    The thesis_type field (thesis/mini_thesis check constraint) is
    ...                required; omitting it shows a validation error.
    [Tags]    regression    supervisor    sop    negative    pending
    Navigate To Create SoP
    # Skip thesis_type selection
    Input Text    id=background_to_study    ${SOP_BACKGROUND}
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    thesis_type

# ────────────────────────────────────────────────────────────────────────────────
# Thesis Submission
# ────────────────────────────────────────────────────────────────────────────────

Supervisor Can Access Thesis Submission Form
    [Tags]    smoke    supervisor    thesis    pending
    Navigate To Submit Thesis
    Element Should Be Visible    css=form

# ────────────────────────────────────────────────────────────────────────────────
# Progress Report – comment and sign
# ────────────────────────────────────────────────────────────────────────────────

Supervisor Can View Pending Progress Reports
    [Tags]    smoke    supervisor    progress-report    pending
    Navigate To Pending Progress Reports
    Page Should Contain Element    css=table, css=[role="list"]

Supervisor Can Comment On A Progress Report
    [Tags]    smoke    supervisor    progress-report    pending
    Open Progress Report For Review    ${STUDENT_FULL_NAME}
    Add Supervisor Comment    ${SUPERVISOR_COMMENT}

Supervisor Can Sign A Progress Report
    [Documentation]    After commenting, the supervisor digitally signs the report,
    ...                which sets supervisor_reviews.signed_at.
    [Tags]    smoke    supervisor    progress-report    sign    pending
    Comment And Sign Progress Report    ${STUDENT_FULL_NAME}

Supervisor Cannot Sign Without Entering A Comment
    [Tags]    regression    supervisor    progress-report    negative    pending
    Open Progress Report For Review    ${STUDENT_FULL_NAME}
    # Clear comment box and attempt to sign
    Clear Element Text    id=supervisor_comment
    Click Element    xpath=//button[contains(text(),'Sign')]
    Field Should Show Validation Error    supervisor_comment

# ────────────────────────────────────────────────────────────────────────────────
# Thesis Grading
# ────────────────────────────────────────────────────────────────────────────────

Supervisor Can Grade Thesis As Pass
    [Tags]    smoke    supervisor    grading    pending
    Grade Thesis    ${STUDENT_FULL_NAME}    Pass

Supervisor Can Grade Thesis As Pass With Minor Corrections
    [Tags]    regression    supervisor    grading    pending
    Grade Thesis    ${STUDENT_FULL_NAME}    Pass with Minor Corrections

# ────────────────────────────────────────────────────────────────────────────────
# Student monitoring
# ────────────────────────────────────────────────────────────────────────────────

Supervisor Can View My Students List
    [Tags]    smoke    supervisor    monitoring    pending
    Navigate To My Students
    Page Should Contain    ${STUDENT_FULL_NAME}

Supervisor Can View A Student Progress Detail
    [Tags]    smoke    supervisor    monitoring    pending
    View Student Progress    ${STUDENT_FULL_NAME}
    Page Should Contain Element    css=main
