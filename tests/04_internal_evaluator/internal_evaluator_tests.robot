*** Settings ***
Documentation    Internal Evaluator module test suite.
...
...              Logged-in user : Dr. Elizabeth Kamati (e.kamati@nust.na)
...              Role           : evaluator  (seed, demo-seed id=102)
...
...              Business processes automated
...              ────────────────────────────
...              • View assigned proposals (evaluator_assignments table)
...              • Evaluate proposal (submission_evaluations)
...              • Complete and sign the proposal Checklist
...                (proposal_checklists / checklist_responses)
...
...              Submission under test (demo-seed.sql)
...              ─────────────────────────────────────
...              submission id=5, student_id=100, status='under_internal_eval'
...              evaluator_assignment: evaluator_id=102, type='internal', status='pending'
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/evaluator_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Internal Evaluator Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    int_eval_fail

*** Test Cases ***

Internal Evaluator Lands On Dashboard After Login
    [Tags]    smoke    internal-evaluator    login
    Location Should Contain    ${URL_DASHBOARD}

Internal Evaluator Can View Assigned Proposals
    [Documentation]    The evaluator_assignments list for e.kamati@nust.na includes
    ...                the demo-seed submission (id=5, Tendai Moyo).
    [Tags]    smoke    internal-evaluator    proposals    pending
    Navigate To Assigned Proposals
    Page Should Contain    ${STUDENT_FULL_NAME}

Internal Evaluator Can Open A Proposal Evaluation Form
    [Tags]    smoke    internal-evaluator    proposals    pending
    Open Proposal Evaluation Form    ${STUDENT_FULL_NAME}
    Element Should Be Visible    id=evaluation_remarks

Internal Evaluator Can Approve A Proposal
    [Documentation]    Evaluates with outcome=approved; submission_evaluations record created.
    [Tags]    smoke    internal-evaluator    proposals    evaluate    pending
    Open Proposal Evaluation Form    ${STUDENT_FULL_NAME}
    Evaluate Proposal    ${EVALUATOR_REMARKS}    approved

Internal Evaluator Can Reject A Proposal With Remarks
    [Tags]    regression    internal-evaluator    proposals    evaluate    pending
    Open Proposal Evaluation Form    ${STUDENT_FULL_NAME}
    Evaluate Proposal    Insufficient literature review. Resubmission required.    rejected

Internal Evaluator Cannot Submit Without Remarks
    [Documentation]    The evaluation_remarks field is required.
    [Tags]    regression    internal-evaluator    proposals    negative    pending
    Open Proposal Evaluation Form    ${STUDENT_FULL_NAME}
    Select From List By Value    id=outcome    approved
    Clear Element Text    id=evaluation_remarks
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    evaluation_remarks

Internal Evaluator Can View Proposal Checklist
    [Tags]    smoke    internal-evaluator    checklist    pending
    Navigate To Proposal Checklist
    Element Should Be Visible    css=form

Internal Evaluator Can Complete And Sign Checklist
    [Documentation]    All checklist_responses checkboxes are selected then signed.
    [Tags]    smoke    internal-evaluator    checklist    sign    pending
    Navigate To Proposal Checklist
    Complete And Sign Checklist

Internal Evaluator Cannot Sign Checklist With Unchecked Items
    [Documentation]    Attempting to sign without checking all items shows an error.
    [Tags]    regression    internal-evaluator    checklist    negative    pending
    Navigate To Proposal Checklist
    # Leave all checkboxes unchecked
    Click Element    xpath=//button[contains(text(),'Sign') or contains(text(),'Submit')]
    # Expect validation error
    Page Should Contain Element    css=[role="alert"], xpath=//*[contains(@class,'text-red') or contains(@class,'alert')]
