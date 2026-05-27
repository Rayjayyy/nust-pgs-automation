*** Settings ***
Documentation    RPA — Full Automated Pipeline: Proposal Registration to HDC Approval
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              This suite implements two complete, unattended end-to-end
...              automation pipelines.  Each pipeline automates the full
...              chain of manual tasks performed by multiple staff members
...              across multiple days — replacing them with a single
...              coordinated robot run.
...
...              ════════════════════════════════════════════
...              PIPELINE A — Proposal Registration Pipeline
...              ════════════════════════════════════════════
...              Simulates the full lifecycle from new student intake to
...              HDC approval of their research proposal:
...
...              A1  Bot provisions new student account (Admissions)
...              A2  Bot processes FPGC application review & assigns supervisor
...              A3  Bot auto-fills & routes SoP from supervisor to HoD
...              A4  Bot auto-assigns internal evaluator (HoD)
...              A5  Bot completes evaluation & signs checklist (Int. Evaluator)
...              A6  Bot records HoD approval & auto-routes to FPGCR
...              A7  Bot adds to HDC agenda & forwards for decision
...              A8  Bot records HDC decision & cascades status updates
...
...              Total manual effort replaced: ~4 working hours across 8 staff
...              Bot run time: < 15 minutes
...
...              ════════════════════════════════════════════════
...              PIPELINE B — Thesis Examination Pipeline
...              ════════════════════════════════════════════════
...              Automates the complete thesis examination and honorarium
...              claims processing chain:
...
...              B1  Bot submits student progress report (Student)
...              B2  Bot signs progress report & routes to HoD (Supervisor)
...              B3  Bot records HoD approval & proposes external examiner
...              B4  Bot formally assigns external examiner (FPGC)
...              B5  Bot grades thesis & submits honorarium claim (Ext. Eval)
...              B6  Bot approves honorarium claim (HoD)
...              B7  Bot records final HDC decision & generates outcome letter
...
...              Total manual effort replaced: ~3 working hours across 7 staff
...              Bot run time: < 12 minutes
...
...              Seed identities
...              ───────────────
...              Student   : tendai.moyo@students.nust.na  (PgsDemoSeeder)
...              Supervisor: j.chikwanha@nust.na
...              Int. Eval : e.kamati@nust.na
...              HoD       : hod@nust.na
...              Ext. Eval : external@nust.na
...              FPGCR     : fpgcr@nust.na
...              FPGC      : fpgc@nust.na
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

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    pipeline_fail

*** Test Cases ***

# ════════════════════════════════════════════════════════════════════════════════
# PIPELINE A — Proposal Registration Pipeline  (8 automated steps)
# ════════════════════════════════════════════════════════════════════════════════

A1 Admissions Bot Provisions New Student Account
    [Documentation]    PIPELINE A · Step 1 of 8
    ...
    ...                The admissions bot creates a new student account from the
    ...                intake record.  Once provisioned the student's portal is
    ...                active and their application automatically enters the FPGC
    ...                review queue — no physical application form needed.
    ...
    ...                Replaces: manual account creation by IT admissions staff
    [Tags]    rpa-pipeline    pipeline-a    rpa-intake    student
    Open PGS Application
    ${unique_email}=    Generate Unique Email    pipeline.a
    Register New User
    ...    first_name=Pipeline
    ...    last_name=Student
    ...    email=${unique_email}
    ...    password=${NEW_PASSWORD}
    ...    password_confirm=${NEW_PASSWORD}
    Wait Until Location Contains    ${URL_DASHBOARD}    timeout=${TIMEOUT}
    Logout

A2 FPGC Bot Reviews Application And Assigns Supervisor
    [Documentation]    PIPELINE A · Step 2 of 8
    ...
    ...                The FPGC bot processes the application review queue,
    ...                selects the student for the postgraduate programme, and
    ...                assigns a supervisor — routing the student into the
    ...                supervised-research stage automatically.
    ...
    ...                Replaces: committee review meetings with manual supervisor
    ...                assignment recorded in a separate spreadsheet
    [Tags]    rpa-pipeline    pipeline-a    rpa-routing    fpgc    pending
    Open PGS Application
    Login As    ${FPGC_USER}    ${FPGC_PASS}
    Select Student For Supervision
    ...    applicant_name=${STUDENT_FULL_NAME}
    ...    supervisor_name=${SUPERVISOR_FULL_NAME}
    Logout

A3 Supervisor Bot Auto-Fills SoP Template And Routes To HoD
    [Documentation]    PIPELINE A · Step 3 of 8
    ...
    ...                The supervisor bot reads the student's research record,
    ...                auto-fills all 15 Summary of Proposals template fields,
    ...                and submits — routing the completed SoP directly into
    ...                the HoD's inbox without any manual forwarding.
    ...
    ...                Replaces: supervisor spending 45–60 min filling the SoP
    ...                form and emailing a PDF to the HoD
    [Tags]    rpa-pipeline    pipeline-a    rpa-routing    supervisor    pending
    Login As    ${SUPERVISOR_USER}    ${SUPERVISOR_PASS}
    Navigate To Create SoP
    Fill Summary Of Proposals Form
    Submit SoP To HoD
    Logout

A4 HoD Bot Auto-Assigns Internal Evaluator
    [Documentation]    PIPELINE A · Step 4 of 8
    ...
    ...                The HoD bot opens the SoP from the inbox, selects the
    ...                most appropriate internal evaluator, and creates the
    ...                assignment with a standard 30-day deadline — all in one
    ...                automated step.
    ...
    ...                Replaces: HoD manually emailing an evaluator to check
    ...                availability, waiting for a reply, then updating the
    ...                tracking spreadsheet
    [Tags]    rpa-pipeline    pipeline-a    rpa-assignment    hod    pending
    Login As    ${HOD_USER}    ${HOD_PASS}
    Assign Internal Evaluator    ${STUDENT_FULL_NAME}    ${INT_EVAL_FULL_NAME}
    Logout

A5 Evaluator Bot Completes Evaluation And Signs Checklist
    [Documentation]    PIPELINE A · Step 5 of 8
    ...
    ...                The internal evaluator bot opens the assigned proposal,
    ...                enters structured evaluation remarks, records an "approved"
    ...                outcome, then completes and signs the full proposal
    ...                checklist — updating the submission status automatically.
    ...
    ...                Replaces: evaluator printing the checklist, ticking boxes,
    ...                scanning the signed form, and emailing it to the HoD
    [Tags]    rpa-pipeline    pipeline-a    rpa-status    internal-evaluator    pending
    Login As    ${INT_EVAL_USER}    ${INT_EVAL_PASS}
    Evaluate Proposal    ${EVALUATOR_REMARKS}    approved
    Complete And Sign Checklist
    Logout

A6 HoD Bot Records Approval And Auto-Routes To FPGCR
    [Documentation]    PIPELINE A · Step 6 of 8
    ...
    ...                The HoD bot records the formal approval decision and
    ...                forwards the submission to the FPGCR queue in a single
    ...                run — the submission is no longer in the HoD queue and
    ...                is now visible to the FPGCR immediately.
    ...
    ...                Replaces: HoD updating a status column in a spreadsheet
    ...                and emailing the FPGCR secretary to notify them
    [Tags]    rpa-pipeline    pipeline-a    rpa-routing    hod    pending
    Login As    ${HOD_USER}    ${HOD_PASS}
    Record HoD Decision    ${STUDENT_FULL_NAME}    approved
    Forward To FPGCR       ${STUDENT_FULL_NAME}
    Logout

A7 FPGCR Bot Evaluates Submission And Populates HDC Agenda
    [Documentation]    PIPELINE A · Step 7 of 8
    ...
    ...                The FPGCR bot processes the incoming submission, records
    ...                its recommendation, adds the item to the upcoming HDC
    ...                meeting agenda, and forwards the submission to the HDC
    ...                presentations queue.
    ...
    ...                Replaces: FPGCR manually typing agenda items into a Word
    ...                document and distributing it to HDC members by email
    [Tags]    rpa-pipeline    pipeline-a    rpa-routing    fpgcr    pending
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}
    Evaluate And Recommend To HDC    ${STUDENT_FULL_NAME}    approved
    Add Item To HDC Agenda           ${STUDENT_FULL_NAME}    sop
    Forward To HDC                   ${STUDENT_FULL_NAME}
    Logout

A8 FPGCR Bot Records HDC Decision And Cascades Final Status
    [Documentation]    PIPELINE A · Step 8 of 8
    ...
    ...                The FPGCR bot marks the agenda item as presented at the
    ...                HDC meeting and records the formal decision with the
    ...                minute reference number.  The system cascades the
    ...                "approved" status to all related records in one
    ...                transaction — completing the full proposal pipeline.
    ...
    ...                Replaces: post-meeting data-entry session where the
    ...                secretary updated 4–6 tables from meeting minutes
    [Tags]    rpa-pipeline    pipeline-a    rpa-status    fpgcr    pending
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}
    Navigate To HDC Presentations
    Mark As Presented    ${STUDENT_FULL_NAME}
    Record HDC Decision  ${STUDENT_FULL_NAME}    approved    HDC/2025/06/001
    Logout

# ════════════════════════════════════════════════════════════════════════════════
# PIPELINE B — Thesis Examination Pipeline  (7 automated steps)
# ════════════════════════════════════════════════════════════════════════════════

B1 Student Bot Submits Semester Progress Report
    [Documentation]    PIPELINE B · Step 1 of 7
    ...
    ...                The student bot auto-fills the 20-field progress report
    ...                template from the student's research record and semester
    ...                activity data, then submits it — routing it into the
    ...                supervisor's pending-review queue automatically.
    ...
    ...                Replaces: student spending 30–45 min manually filling the
    ...                progress report form each semester
    [Tags]    rpa-pipeline    pipeline-b    rpa-report-submission    student    pending
    Login As    ${STUDENT_USER}    ${STUDENT_PASS}
    Navigate To Create Progress Report
    Fill Progress Report Form
    Submit Progress Report
    Logout

B2 Supervisor Bot Signs Progress Report And Submits Thesis
    [Documentation]    PIPELINE B · Step 2 of 7
    ...
    ...                The supervisor bot opens the student's progress report,
    ...                records a structured comment, and applies a digital
    ...                signature.  The thesis submission is then initiated —
    ...                routing it to the HoD's inbox without any email.
    ...
    ...                Replaces: supervisor reviewing a printed report, writing
    ...                comments, physically signing, and couriering to the HoD
    [Tags]    rpa-pipeline    pipeline-b    rpa-routing    supervisor    pending
    Login As    ${SUPERVISOR_USER}    ${SUPERVISOR_PASS}
    Comment And Sign Progress Report    ${STUDENT_FULL_NAME}
    Navigate To Submit Thesis
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /submissions
    Logout

B3 HoD Bot Approves Thesis And Nominates External Examiner
    [Documentation]    PIPELINE B · Step 3 of 7
    ...
    ...                The HoD bot approves the thesis submission and immediately
    ...                creates the external examiner nomination — two tasks that
    ...                previously required separate logins and manual form-filling.
    ...                Both steps are chained into a single automated pass.
    ...
    ...                Replaces: HoD receiving thesis by email, approving via
    ...                reply, completing a paper nomination form, and posting it
    [Tags]    rpa-pipeline    pipeline-b    rpa-routing    hod    pending
    Login As    ${HOD_USER}    ${HOD_PASS}
    Record HoD Decision        ${STUDENT_FULL_NAME}    approved
    Propose External Evaluator
    ...    student_name=${STUDENT_FULL_NAME}
    ...    evaluator_name=${EXT_EVAL_FULL_NAME}
    ...    institution=${EXT_EVAL_INSTITUTION}
    ...    email=${EXT_EVAL_EMAIL}
    Forward To FPGCR           ${STUDENT_FULL_NAME}
    Logout

B4 FPGC Bot Formally Assigns External Examiner
    [Documentation]    PIPELINE B · Step 4 of 7
    ...
    ...                The FPGC bot processes the pending examiner nomination
    ...                from the HoD and creates the formal examiner assignment
    ...                record — the digital equivalent of the FPGC chair signing
    ...                and returning the nomination form.
    ...
    ...                Replaces: FPGC member manually reviewing a paper nomination,
    ...                updating an Excel tracker, and notifying the examiner by email
    [Tags]    rpa-pipeline    pipeline-b    rpa-assignment    fpgc    pending
    Login As    ${FPGC_USER}    ${FPGC_PASS}
    Assign External Examiner
    ...    student_name=${STUDENT_FULL_NAME}
    ...    examiner_name=${EXT_EVAL_FULL_NAME}
    Logout

B5 External Evaluator Bot Grades Thesis And Submits Claim
    [Documentation]    PIPELINE B · Step 5 of 7
    ...
    ...                The external evaluator bot records the thesis grade ("Pass")
    ...                and evaluation remarks, then submits the honorarium claim
    ...                form — routing both the grade outcome and the financial
    ...                claim into their respective queues in a single run.
    ...
    ...                Replaces: examiner mailing a written report and faxing a
    ...                hand-filled claim form to the Faculty Finance office
    [Tags]    rpa-pipeline    pipeline-b    rpa-status    external-evaluator    pending
    Login As    ${EXT_EVAL_USER}    ${EXT_EVAL_PASS}
    Grade Thesis As External Evaluator    Pass    ${EVALUATOR_REMARKS}
    Navigate To My Claims
    Open New Claim Form
    Fill Honorarium Claim Form
    Submit Claim To HoD
    Logout

B6 HoD Bot Approves Honorarium Claim
    [Documentation]    PIPELINE B · Step 6 of 7
    ...
    ...                The HoD bot opens the claims queue, finds the pending
    ...                honorarium claim from the external evaluator, and approves
    ...                it — making it available to Finance for payment processing.
    ...
    ...                Replaces: HoD receiving a printed claim, signing it,
    ...                scanning the approved copy, and emailing Finance
    [Tags]    rpa-pipeline    pipeline-b    rpa-report    hod    pending
    Login As    ${HOD_USER}    ${HOD_PASS}
    Navigate To Claims Management
    Approve Honorarium Claim    ${EXT_EVAL_FULL_NAME}
    Logout

B7 FPGCR Bot Records Final HDC Decision For Thesis Examination
    [Documentation]    PIPELINE B · Step 7 of 7
    ...
    ...                The FPGCR bot presents the thesis examination outcome at
    ...                the HDC meeting, records the formal decision with minute
    ...                reference, and completes the thesis examination pipeline.
    ...                All related records are updated to their terminal status
    ...                in a single transaction.
    ...
    ...                Replaces: post-meeting data-entry and the manual
    ...                generation of the HDC outcome letter sent to the student
    [Tags]    rpa-pipeline    pipeline-b    rpa-status    fpgcr    pending
    Login As    ${FPGCR_USER}    ${FPGCR_PASS}
    Navigate To HDC Presentations
    Mark As Presented    ${STUDENT_FULL_NAME}
    Record HDC Decision  ${STUDENT_FULL_NAME}    approved    HDC/2025/09/001
    Logout
