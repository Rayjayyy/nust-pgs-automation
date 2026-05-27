*** Settings ***
Documentation    Faculty Postgraduate Committee module test suite.
...
...              Logged-in user : fpgc@nust.na (seed.sql)
...
...              Business processes automated
...              ────────────────────────────
...              • Review postgraduate applications (pg_applications)
...              • Select students for supervision
...                (supervision_relationships – second_co_supervisor_id migration)
...              • Reject applications (application_reviews)
...              • Assign external examiners (evaluator_assignments, type='external')
...              • Generate postgraduate activity report (report_snapshots)
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/fpgc_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      FPGC Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    fpgc_fail

*** Test Cases ***

FPGC Lands On Dashboard After Login
    [Tags]    smoke    fpgc    login
    Location Should Contain    ${URL_DASHBOARD}

FPGC Can View Postgraduate Applications
    [Tags]    smoke    fpgc    applications    pending
    Navigate To Applications
    Page Should Contain Element    css=table

FPGC Can Open An Application
    [Tags]    smoke    fpgc    applications    pending
    Open Application    ${STUDENT_FULL_NAME}
    Page Should Contain Element    css=main

FPGC Can Review Application Details
    [Tags]    smoke    fpgc    applications    pending
    Open Application    ${STUDENT_FULL_NAME}
    Review Application Details

FPGC Can Select Student For Supervision With Assigned Supervisor
    [Documentation]    Creates supervision_relationships record; assigns supervisor.
    [Tags]    smoke    fpgc    supervision    pending
    Select Student For Supervision
    ...    applicant_name=${STUDENT_FULL_NAME}
    ...    supervisor_name=${SUPERVISOR_FULL_NAME}

FPGC Cannot Select Student Without Assigning Supervisor
    [Tags]    regression    fpgc    supervision    negative    pending
    Open Application    ${STUDENT_FULL_NAME}
    # Skip supervisor dropdown
    Click Element    xpath=//button[contains(text(),'Select for Supervision')]
    Field Should Show Validation Error    supervisor_id

FPGC Can Reject An Application With A Reason
    [Tags]    regression    fpgc    applications    pending
    Reject Application
    ...    applicant_name=${STUDENT_FULL_NAME}
    ...    reason=Does not meet minimum entry requirements

FPGC Can View External Examiner Panel
    [Tags]    smoke    fpgc    external-examiner    pending
    Navigate To External Examiner Assignments
    Page Should Contain Element    css=main

FPGC Can Assign External Examiner To A Student
    [Documentation]    Creates evaluator_assignments record with type='external'.
    [Tags]    smoke    fpgc    external-examiner    assign    pending
    Assign External Examiner
    ...    student_name=${STUDENT_FULL_NAME}
    ...    examiner_name=${EXT_EVAL_FULL_NAME}

FPGC Cannot Assign Examiner Without Selecting One
    [Tags]    regression    fpgc    external-examiner    negative    pending
    Navigate To External Examiner Assignments
    Click Element    xpath=//tr[contains(.,'${STUDENT_FULL_NAME}')]//a[contains(text(),'Assign')]
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    external_examiner_id

FPGC Can Generate Postgraduate Activity Report
    [Documentation]    Triggers report_snapshots record creation; download link appears.
    [Tags]    smoke    fpgc    report    pending
    Navigate To Reports
    Generate Postgraduate Activity Report

FPGC Can Download The Generated Report
    [Tags]    regression    fpgc    report    pending
    Navigate To Reports
    Generate Postgraduate Activity Report
    Download Report
