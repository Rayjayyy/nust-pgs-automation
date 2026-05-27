*** Settings ***
Documentation    FPGC Representative module test suite.
...
...              Logged-in user : fpgcr@nust.na (seed.sql)
...
...              Business processes automated
...              ────────────────────────────
...              • Evaluate HoD submissions
...              • Add items to HDC agenda (hdc_presentations)
...              • Forward submissions to HDC
...              • Mark items as presented at HDC meeting
...              • Record HDC decision (hdc_decisions – decision_type enum)
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/fpgcr_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      FPGCR Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    fpgcr_fail

*** Test Cases ***

FPGCR Lands On Dashboard After Login
    [Tags]    smoke    fpgcr    login
    Location Should Contain    ${URL_DASHBOARD}

FPGCR Can View Inbox
    [Tags]    smoke    fpgcr    inbox    pending
    Navigate To FPGCR Inbox
    Page Should Contain Element    css=table

FPGCR Can Open A Submission
    [Tags]    smoke    fpgcr    inbox    pending
    Open FPGCR Submission    ${STUDENT_FULL_NAME}
    Page Should Contain Element    css=main

FPGCR Can Recommend Submission For HDC
    [Documentation]    Records decision=approved in the FPGCR evaluation step.
    [Tags]    smoke    fpgcr    evaluation    pending
    Evaluate And Recommend To HDC    ${STUDENT_FULL_NAME}    approved

FPGCR Can Request Revision Before HDC
    [Tags]    regression    fpgcr    evaluation    pending
    Evaluate And Recommend To HDC    ${STUDENT_FULL_NAME}    revisions_required

FPGCR Cannot Submit Evaluation Without A Decision
    [Tags]    regression    fpgcr    evaluation    negative    pending
    Open FPGCR Submission    ${STUDENT_FULL_NAME}
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    fpgcr_decision

FPGCR Can View HDC Agenda
    [Tags]    smoke    fpgcr    hdc    agenda    pending
    Navigate To HDC Agenda
    Page Should Contain Element    css=main

FPGCR Can Add A Thesis Item To HDC Agenda
    [Documentation]    Creates a hdc_presentations record for the student submission.
    [Tags]    smoke    fpgcr    hdc    agenda    pending
    Add Item To HDC Agenda    ${STUDENT_FULL_NAME}    thesis

FPGCR Can Add A SoP Item To HDC Agenda
    [Tags]    regression    fpgcr    hdc    agenda    pending
    Add Item To HDC Agenda    ${STUDENT_FULL_NAME}    sop

FPGCR Can Forward Submission To HDC
    [Tags]    smoke    fpgcr    hdc    forward    pending
    Forward To HDC    ${STUDENT_FULL_NAME}

FPGCR Can View Presentations List
    [Tags]    smoke    fpgcr    hdc    presentation    pending
    Navigate To HDC Presentations
    Page Should Contain Element    css=table

FPGCR Can Mark A Submission As Presented At HDC
    [Documentation]    Sets hdc_presentations.presented_at timestamp.
    [Tags]    smoke    fpgcr    hdc    presentation    pending
    Navigate To HDC Presentations
    Mark As Presented    ${STUDENT_FULL_NAME}

FPGCR Can Record HDC Approved Decision
    [Documentation]    Creates a hdc_decisions record with decision=approved and
    ...                the minute reference number.
    [Tags]    smoke    fpgcr    hdc    decision    pending
    Navigate To HDC Presentations
    Record HDC Decision    ${STUDENT_FULL_NAME}    approved    HDC/2025/06/001

FPGCR Can Record HDC Revision Required Decision
    [Tags]    regression    fpgcr    hdc    decision    pending
    Navigate To HDC Presentations
    Record HDC Decision    ${STUDENT_FULL_NAME}    revisions_required    HDC/2025/06/002

FPGCR Can Record HDC Deferred Decision
    [Tags]    regression    fpgcr    hdc    decision    pending
    Navigate To HDC Presentations
    Record HDC Decision    ${STUDENT_FULL_NAME}    deferred    HDC/2025/06/003
