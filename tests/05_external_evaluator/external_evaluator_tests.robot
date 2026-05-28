*** Settings ***
Documentation    RPA — External Examination Processing & Honorarium Claims Automation
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              External evaluators are engaged per examination and must:
...              (1) grade the assigned thesis and submit a report, and
...              (2) submit an honorarium claim for Finance processing.
...              Both steps involve repetitive form-filling that the bot
...              automates from the evaluator's pre-prepared data.
...
...              PROCESS 1 — Thesis Grading & Examination Report Submission
...              The bot reads the evaluator's grading decision and remarks,
...              opens the thesis_evaluations form, records the grade and
...              narrative, and submits.  Status is automatically updated
...              from "awaiting_external_evaluation" to "externally_evaluated".
...
...              PROCESS 2 — Honorarium Claim Form Automation
...              Evaluators previously completed a 12-field paper claim form,
...              which was faxed to HR.  The bot fills the digital claim form
...              (honorarium_claims + claim_service_lines tables) and routes
...              it to the HoD's approval queue automatically.
...
...              Bot identity : external@nust.na  (PgsDemoSeeder)
...              DB tables    : thesis_evaluations · honorarium_claims
...                            · claim_service_lines · external_evaluator_profiles
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/evaluator_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      External Evaluator Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    external_eval_fail

*** Test Cases ***

Bot Confirms External Evaluator Portal Access
    [Documentation]    The external evaluator bot authenticates and confirms
    ...                dashboard access before beginning the examination run.
    [Tags]    rpa-auth    portal-check    external-evaluator
    Location Should Contain    ${URL_DASHBOARD}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 1 — Thesis Grading & Examination Report
# ════════════════════════════════════════════════════════════════════════════

Bot Retrieves Assigned Thesis Queue For Examination
    [Documentation]    The bot opens /external-evaluations/theses to see the
    ...                list of theses assigned for external examination.  This
    ...                is the starting point for the automated grading batch run.
    [Tags]    rpa-assignment    thesis-examination    external-evaluator    pending
    Navigate To Assigned Theses
    Page Should Contain Element    css=table, css=[role="list"]

Bot Opens Thesis For Grading
    [Documentation]    The bot navigates to the grading form for the assigned
    ...                student's thesis — confirming the grade dropdown is
    ...                available before entering the examination decision.
    [Tags]    rpa-assignment    thesis-grading    external-evaluator    pending
    Open Thesis Grading Form    ${STUDENT_FULL_NAME}
    Element Should Be Visible    id=grade

Bot Records Examination Decision And Updates Thesis Status
    [Documentation]    The bot selects "Pass" from the grade_sheet dropdown,
    ...                enters the structured evaluation remarks, and submits.
    ...                The system automatically updates the thesis status to
    ...                "externally_evaluated" — no separate admin action needed.
    ...
    ...                Manual task replaced: examiners sent hand-written reports
    ...                by post or email, which a secretary then typed into the
    ...                system.  The bot bypasses this entire paper chain.
    [Tags]    rpa-status    thesis-grading    auto-status-update    external-evaluator    pending
    Grade Thesis As External Evaluator    Pass    ${EVALUATOR_REMARKS}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 2 — Honorarium Claim Form Automation
# ════════════════════════════════════════════════════════════════════════════

Bot Opens Claim Management Section
    [Documentation]    The bot opens /claims — the starting point for the
    ...                honorarium claim submission batch.
    [Tags]    rpa-report    claim-processing    external-evaluator    pending
    Navigate To My Claims
    Page Should Contain Element    css=main

Bot Auto-Fills 12-Field Honorarium Claim From Evaluator Record
    [Documentation]    The bot opens a new claim form and populates all 12
    ...                personal and banking fields (surname, names, programme,
    ...                exam session, year, bank name, account holder, account
    ...                number, branch code) from the evaluator's pre-stored
    ...                profile and the current examination session data.
    ...
    ...                Manual task replaced: evaluators completed a paper
    ...                claim form (sometimes incorrectly), which was checked
    ...                by Finance staff and returned for correction.  The bot
    ...                pulls validated banking data from the system record,
    ...                eliminating the most common error source.
    [Tags]    rpa-report    claim-processing    external-evaluator    pending
    Open New Claim Form
    Fill Honorarium Claim Form

Bot Routes Completed Claim To HoD Approval Queue
    [Documentation]    After filling the claim the bot submits it, which
    ...                automatically places it in the HoD's approval queue.
    ...                This replaces the manual process of emailing the claim
    ...                PDF to the HoD and waiting for an email acknowledgement.
    [Tags]    rpa-routing    claim-submission    auto-routing    external-evaluator    pending
    Submit Claim To HoD

Bot Synchronises Evaluator Profile For Future Claims
    [Documentation]    The bot reads the external evaluator's profile page and
    ...                updates institution and expertise fields — ensuring future
    ...                automated claim batches use current, accurate data.
    [Tags]    rpa-status    profile-sync    external-evaluator    pending
    Navigate To Evaluator Profile
    Update Evaluator Profile
    ...    institution=${EXT_EVAL_INSTITUTION}
    ...    expertise=${EXT_EVAL_SPECIALISATION}
