*** Settings ***
Documentation    End-to-end workflow tests for the NUST Postgraduate Digital System.
...
...              Two complete business-process chains are modelled here.
...              Each chain is a sequence of individually-tagged test cases
...              that must run in document order (--order document).
...
...              ════════════════════════════════════════════════════
...              WORKFLOW A – Proposal Pipeline
...              ════════════════════════════════════════════════════
...              A1  Student registers a new account
...              A2  FPGC reviews the application and assigns a Supervisor
...              A3  Supervisor fills and submits the Summary of Proposals
...              A4  HoD assigns an Internal Evaluator to the proposal
...              A5  Internal Evaluator evaluates and signs the Checklist
...              A6  HoD records an Approved decision and forwards to FPGC-R
...              A7  FPGC-R evaluates, adds item to HDC agenda, forwards to HDC
...              A8  FPGC-R presents at HDC and records the final decision
...
...              ════════════════════════════════════════════════════
...              WORKFLOW B – Thesis Examination Pipeline
...              ════════════════════════════════════════════════════
...              B1  Student submits Progress Report
...              B2  Supervisor comments, signs, and submits thesis to HoD
...              B3  HoD proposes External Evaluator and forwards to FPGC-R
...              B4  FPGC assigns External Examiner
...              B5  External Evaluator grades thesis and submits honorarium claim
...              B6  HoD approves the honorarium claim
...              B7  FPGC-R records final HDC decision
...
...              Seed data
...              ─────────
...              Student   : tendai.moyo@students.nust.na  (demo-seed id=100)
...              Supervisor: j.chikwanha@nust.na            (demo-seed id=101)
...              Int.Eval  : e.kamati@nust.na               (demo-seed id=102)
...              Others    : seed.sql  (hod, external, fpgcr, fpgc)
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/student_keywords.resource
Resource         ../../resources/supervisor_keywords.resource
Resource         ../../resources/evaluator_keywords.resource
Resource         ../../resources/hod_keywords.resource
Resource         ../../resources/fpgcr_keywords.resource
Resource         ../../resources/fpgc_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Teardown   Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    e2e_fail

*** Test Cases ***

# ════════════════════════════════════════════════════════════════════════════════
# WORKFLOW A – Proposal Pipeline
# ════════════════════════════════════════════════════════════════════════════════

A1 Student Registers A New Account
    [Documentation]    A new prospective student registers; CreateNewUser assigns
    ...                role='student' automatically.
    [Tags]    e2e    workflow-a    student
    Open PGS Application
    ${unique_email}=    Generate Unique Email    e2e.workflow.a
    Fill And Submit Registration Form
    ...    first_name=E2E
    ...    last_name=Student
    ...    email=${unique_email}
    ...    password=${NEW_PASSWORD}
    ...    password_confirm=${NEW_PASSWORD}
    Wait Until Location Contains    ${URL_DASHBOARD}    timeout=${TIMEOUT}
    Logout

A2 FPGC Selects Student For Supervision
    [Documentation]    FPGC reviews the application and assigns a supervisor.
    [Tags]    e2e    workflow-a    fpgc    pending
    Open PGS Application
    Login As    ${FPGC_USER}    ${FPGC_PASS}
    Select Student For Supervision
    ...    applicant_name=${STUDENT_FULL_NAME}
    ...    supervisor_name=${SUPERVISOR_FULL_NAME}
    Logout

A3 Supervisor Submits Summary Of Proposals To HoD
    [Documentation]    Supervisor fills all 15 template fields and submits SoP.
    [Tags]    e2e    workflow-a    supervisor    pending
    Login As    ${SUPERVISOR_USER}    ${SUPERVISOR_PASS}
    Navigate To Create SoP
    Fill Summary Of Proposals Form
    Submit SoP To HoD
    Logout

A4 HoD Assigns Internal Evaluator
    [Documentation]    HoD assigns Dr. Kamati (id=102) to the proposal.
    [Tags]    e2e    workflow-a    hod    pending
    Login As    ${HOD_USER}    ${HOD_PASS}
    Assign Internal Evaluator    ${STUDENT_FULL_NAME}    ${INT_EVAL_FULL_NAME}
    Logout

A5 Internal Evaluator Evaluates Proposal And Signs Checklist
    [Documentation]    Dr. Kamati approves the proposal and signs the Checklist.
    [Tags]    e2e    workflow-a    internal-evaluator    pending
    Login As    ${INT_EVAL_USER}    ${INT_EVAL_PASS}
    Evaluate Proposal    ${EVALUATOR_REMARKS}    approved
    Complete And Sign Checklist
    Logout

A6 HoD Records Approved Decision And Forwards To FPGCR
    [Documentation]    HoD approves the evaluated SoP and forwards to FPGC-R.
    [Tags]    e2e    workflow-a    hod    pending
    Login As    ${HOD_USER}    ${HOD_PASS}
    Record HoD Decision    ${STUDENT_FULL_NAME}    approved
    Forward To FPGCR       ${STUDENT_FULL_NAME}
    Logout

A7 FPGCR Evaluates And Adds Item To HDC Agenda
    [Documentation]    FPGC-R recommends the SoP and adds it to the HDC agenda.
    [Tags]    e2e    workflow-a    fpgcr    pending
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}
    Evaluate And Recommend To HDC    ${STUDENT_FULL_NAME}    approved
    Add Item To HDC Agenda           ${STUDENT_FULL_NAME}    sop
    Forward To HDC                   ${STUDENT_FULL_NAME}
    Logout

A8 FPGCR Presents At HDC And Records Final Decision
    [Documentation]    FPGC-R marks the SoP as presented and records HDC Approved.
    [Tags]    e2e    workflow-a    fpgcr    hdc    pending
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}
    Navigate To HDC Presentations
    Mark As Presented    ${STUDENT_FULL_NAME}
    Record HDC Decision  ${STUDENT_FULL_NAME}    approved    HDC/2025/06/001
    Logout

# ════════════════════════════════════════════════════════════════════════════════
# WORKFLOW B – Thesis Examination Pipeline
# ════════════════════════════════════════════════════════════════════════════════

B1 Student Submits Progress Report
    [Documentation]    Tendai Moyo fills the 20-field Progress Report template.
    [Tags]    e2e    workflow-b    student    pending
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
    Navigate To Create Progress Report
    Fill Progress Report Form
    Submit Progress Report
    Logout

B2 Supervisor Comments Signs And Submits Thesis To HoD
    [Documentation]    Prof. Chikwanha signs the Progress Report then submits thesis.
    [Tags]    e2e    workflow-b    supervisor    pending
    Login As    ${SUPERVISOR_USER}    ${SUPERVISOR_PASS}
    Comment And Sign Progress Report    ${STUDENT_FULL_NAME}
    Navigate To Submit Thesis
    # Thesis file would be selected here in a real run
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /submissions
    Logout

B3 HoD Proposes External Evaluator And Forwards To FPGCR
    [Documentation]    HoD approves the thesis submission, proposes Dr. Moyo as
    ...                external evaluator, and forwards to FPGC-R.
    [Tags]    e2e    workflow-b    hod    pending
    Login As    ${HOD_USER}    ${HOD_PASS}
    Record HoD Decision        ${STUDENT_FULL_NAME}    approved
    Propose External Evaluator
    ...    student_name=${STUDENT_FULL_NAME}
    ...    evaluator_name=${EXT_EVAL_FULL_NAME}
    ...    institution=${EXT_EVAL_INSTITUTION}
    ...    email=${EXT_EVAL_EMAIL}
    Forward To FPGCR           ${STUDENT_FULL_NAME}
    Logout

B4 FPGC Assigns External Examiner
    [Documentation]    FPGC formally assigns the HoD-proposed evaluator.
    [Tags]    e2e    workflow-b    fpgc    pending
    Login As    ${FPGC_USER}    ${FPGC_PASS}
    Assign External Examiner
    ...    student_name=${STUDENT_FULL_NAME}
    ...    examiner_name=${EXT_EVAL_FULL_NAME}
    Logout

B5 External Evaluator Grades Thesis And Submits Claim
    [Documentation]    Dr. Moyo grades the thesis Pass and submits an honorarium claim.
    [Tags]    e2e    workflow-b    external-evaluator    pending
    Login As    ${EXT_EVAL_USER}    ${EXT_EVAL_PASS}
    Grade Thesis As External Evaluator    Pass    ${EVALUATOR_REMARKS}
    Navigate To My Claims
    Open New Claim Form
    Fill Honorarium Claim Form
    Submit Claim To HoD
    Logout

B6 HoD Approves Honorarium Claim
    [Documentation]    HoD approves the pending honorarium claim from the evaluator.
    [Tags]    e2e    workflow-b    hod    pending
    Login As    ${HOD_USER}    ${HOD_PASS}
    Navigate To Claims Management
    Approve Honorarium Claim    ${EXT_EVAL_FULL_NAME}
    Logout

B7 FPGCR Records Final HDC Decision
    [Documentation]    FPGC-R presents the thesis outcome at HDC and records Approved.
    [Tags]    e2e    workflow-b    fpgcr    hdc    pending
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}
    Navigate To HDC Presentations
    Mark As Presented    ${STUDENT_FULL_NAME}
    Record HDC Decision  ${STUDENT_FULL_NAME}    approved    HDC/2025/09/001
    Logout
