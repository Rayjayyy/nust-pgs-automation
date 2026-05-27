*** Settings ***
Documentation    External Evaluator module test suite.
...
...              Logged-in user : external@nust.na  (seed.sql)
...
...              Business processes automated
...              ────────────────────────────
...              • Grade assigned thesis (thesis_evaluations table)
...              • Submit honorarium claim to HoD
...                (honorarium_claims + claim_service_lines migration)
...              • Update profile for visibility
...                (external_evaluator_profiles table – schema.sql §7)
...
...              Honorarium claim fields (add_claim_details_to_honorarium_claims_table.php)
...              ─────────────────────────────────────────────────────────────────────────
...              surname, names, programme, exam_session, exam_year,
...              bank_name, account_holder_name, account_number, branch_code,
...              subtotal, tax_amount, total_amount
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/evaluator_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      External Evaluator Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    ext_eval_fail

*** Test Cases ***

External Evaluator Lands On Dashboard After Login
    [Tags]    smoke    external-evaluator    login
    Location Should Contain    ${URL_DASHBOARD}

External Evaluator Can View Assigned Theses
    [Tags]    smoke    external-evaluator    thesis    pending
    Navigate To Assigned Theses
    Page Should Contain Element    css=table

External Evaluator Can Open Thesis Grading Form
    [Tags]    smoke    external-evaluator    thesis    grading    pending
    Open Thesis Grading Form    ${STUDENT_FULL_NAME}
    Element Should Be Visible    id=grade

External Evaluator Can Grade Thesis As Pass
    [Tags]    smoke    external-evaluator    thesis    grading    pending
    Open Thesis Grading Form    ${STUDENT_FULL_NAME}
    Grade Thesis As External Evaluator    Pass

External Evaluator Can Grade Thesis As Pass With Minor Corrections
    [Tags]    regression    external-evaluator    thesis    grading    pending
    Open Thesis Grading Form    ${STUDENT_FULL_NAME}
    Grade Thesis As External Evaluator    Pass with Minor Corrections

External Evaluator Can Grade Thesis As Pass With Major Corrections
    [Tags]    regression    external-evaluator    thesis    grading    pending
    Open Thesis Grading Form    ${STUDENT_FULL_NAME}
    Grade Thesis As External Evaluator    Pass with Major Corrections

External Evaluator Cannot Submit Grade Without Selecting Grade
    [Tags]    regression    external-evaluator    thesis    negative    pending
    Open Thesis Grading Form    ${STUDENT_FULL_NAME}
    Input Text    id=external_remarks    Some remarks.
    # Do not select a grade
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    grade

# ── Honorarium Claim ──────────────────────────────────────────────────────────

External Evaluator Can View Claims Section
    [Tags]    smoke    external-evaluator    claim    pending
    Navigate To My Claims
    Page Should Contain Element    css=main

External Evaluator Can Open New Claim Form
    [Tags]    smoke    external-evaluator    claim    pending
    Navigate To My Claims
    Open New Claim Form
    Element Should Be Visible    id=surname

External Evaluator Can Fill And Submit Honorarium Claim
    [Documentation]    All 12 fields from the honorarium_claims migration are populated.
    [Tags]    smoke    external-evaluator    claim    pending
    Navigate To My Claims
    Open New Claim Form
    Fill Honorarium Claim Form
    Submit Claim To HoD

Claim Requires Surname Field
    [Tags]    regression    external-evaluator    claim    negative    pending
    Navigate To My Claims
    Open New Claim Form
    Clear Element Text    id=surname
    Input Text    id=names         ${CLAIM_NAMES}
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    surname

# ── Profile Management ────────────────────────────────────────────────────────

External Evaluator Can Access Profile Page
    [Tags]    smoke    external-evaluator    profile    pending
    Navigate To Evaluator Profile
    Element Should Be Visible    id=institution

External Evaluator Can Update Institution And Expertise
    [Tags]    smoke    external-evaluator    profile    pending
    Update Evaluator Profile
    ...    institution=${EXT_EVAL_INSTITUTION}
    ...    expertise=${EXT_EVAL_SPECIALISATION}

Profile Update Persists After Reload
    [Tags]    regression    external-evaluator    profile    pending
    Update Evaluator Profile
    Navigate To Evaluator Profile
    ${value}=    Get Element Attribute    id=institution    value
    Should Be Equal As Strings    ${value}    ${EXT_EVAL_INSTITUTION}
