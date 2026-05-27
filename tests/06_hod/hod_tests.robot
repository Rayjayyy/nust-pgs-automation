*** Settings ***
Documentation    Head of Department module test suite.
...
...              Logged-in user : hod@nust.na (seed.sql)
...
...              Business processes automated
...              ────────────────────────────
...              • View submission inbox
...              • Assign Internal Evaluator (evaluator_assignments)
...              • Record HoD decision (hod_decisions)
...              • Forward submission to FPGC-R
...              • Propose External Evaluator (external_examiner_proposals)
...              • Approve honorarium claim
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/hod_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      HoD Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    hod_fail

*** Test Cases ***

HoD Lands On Dashboard After Login
    [Tags]    smoke    hod    login
    Location Should Contain    ${URL_DASHBOARD}

HoD Can View Submission Inbox
    [Tags]    smoke    hod    inbox    pending
    Navigate To HoD Inbox
    Page Should Contain Element    css=table

HoD Can Open A Specific Submission
    [Tags]    smoke    hod    inbox    pending
    Open Submission    ${STUDENT_FULL_NAME}
    Page Should Contain Element    css=main

HoD Can Assign Internal Evaluator To A Proposal
    [Documentation]    Selects Dr. Elizabeth Kamati as internal evaluator;
    ...                creates an evaluator_assignments record.
    [Tags]    smoke    hod    assign-evaluator    pending
    Assign Internal Evaluator    ${STUDENT_FULL_NAME}    ${INT_EVAL_FULL_NAME}

HoD Cannot Assign Without Selecting An Evaluator
    [Tags]    regression    hod    assign-evaluator    negative    pending
    Open Submission    ${STUDENT_FULL_NAME}
    # Skip evaluator dropdown – attempt submit
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    internal_evaluator

HoD Can Record An Approved Decision
    [Documentation]    Records decision=approved in hod_decisions table.
    [Tags]    smoke    hod    decision    pending
    Record HoD Decision    ${STUDENT_FULL_NAME}    approved

HoD Can Record A Revision Required Decision
    [Tags]    regression    hod    decision    pending
    Record HoD Decision    ${STUDENT_FULL_NAME}    revisions_required

HoD Can Forward Submission To FPGCR
    [Tags]    smoke    hod    forward    fpgcr    pending
    Forward To FPGCR    ${STUDENT_FULL_NAME}

HoD Can Propose An External Evaluator
    [Documentation]    Creates an external_examiner_proposals record.
    [Tags]    smoke    hod    propose-evaluator    pending
    Propose External Evaluator
    ...    student_name=${STUDENT_FULL_NAME}
    ...    evaluator_name=${EXT_EVAL_FULL_NAME}
    ...    institution=${EXT_EVAL_INSTITUTION}
    ...    email=${EXT_EVAL_EMAIL}

HoD Cannot Propose Evaluator With Missing Email
    [Tags]    regression    hod    propose-evaluator    negative    pending
    Open Submission    ${STUDENT_FULL_NAME}
    Input Text    id=proposed_evaluator_name         ${EXT_EVAL_FULL_NAME}
    Input Text    id=proposed_evaluator_institution  ${EXT_EVAL_INSTITUTION}
    # Leave email blank
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    proposed_evaluator_email

HoD Can View Honorarium Claims
    [Tags]    smoke    hod    claims    pending
    Navigate To Claims Management
    Page Should Contain Element    css=table

HoD Can Approve An Honorarium Claim
    [Tags]    smoke    hod    claims    pending
    Approve Honorarium Claim    ${EXT_EVAL_FULL_NAME}
