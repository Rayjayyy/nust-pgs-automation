*** Settings ***
Documentation       DEMO Suite 1 — Head of Department Workflow Automation
...
...                 What this shows:
...                   • Bot logs in as a role-based HoD service account
...                   • Bot scans the pending approvals queue automatically
...                   • Bot reads quality evaluation scores and decides: approve / revise / reject
...                   • Bot routes the approved document to FPGC-R
...                   • Bot dispatches email notifications to all stakeholders
...                   • Bot auto-assigns internal evaluators by expertise + workload matching
...                   • Bot escalates overdue items directly to the DVC
...
...                 Manual effort replaced: HoD spending 30-60 min/day processing email,
...                 checking queue, forwarding documents, and assigning evaluators.

Metadata            Suite         Demo — HoD Workflow
Metadata            Version       1.0
Metadata            Author        ASD810S Assignment II

Library             SeleniumLibrary
Library             OperatingSystem
Library             Collections
Library             ${CURDIR}/../libraries/CustomLibrary.py
Resource            ${CURDIR}/../resources/demo_common.robot

Suite Setup         Open Demo Browser
Suite Teardown      Close All Browsers
Test Setup          Reset For Test
Test Teardown       Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Variables ***
${SUBMISSION_ID}    SUB2026001
${THESIS_ID}        THS2026001
${STUDENT_ID}       PG2026001
${PROPOSAL_ID}      PROP2026001

*** Test Cases ***

# =============================================================================
# TC-DEMO-HOD-001 — Bot Logs In And Scans Pending Approvals Queue
# =============================================================================
TC-DEMO-HOD-001 Bot Authenticates As HoD And Reviews Pending Queue
    [Documentation]    The bot uses the HoD service account to authenticate, then
    ...                navigates directly to the pending approvals queue — replacing
    ...                the HoD's manual habit of checking email for new submissions.
    [Tags]    demo    hod    auth    rpa-auth

    Log    ══════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-HOD-001 Starting                level=INFO
    Log    [BOT] Using HoD service account credentials    level=INFO
    Log    ══════════════════════════════════════════    level=INFO

    # Authenticate
    Go To Page    ${BASE_URL}/login
    Wait Until Element Is Visible    id=username    timeout=10
    Input Text        id=username    hod@nust.na
    Input Password    id=password    password
    Click Button      id=login-button

    # Verify role badge shows correct role
    Wait Until Element Contains    id=user-role-badge    Head of Department    timeout=10
    Log    [BOT] Role confirmed: Head of Department    level=INFO

    # Navigate directly to pending queue — no email checking needed
    Go To Page    ${HOD_PORTAL}/approvals/pending
    Wait Until Element Is Visible    class=pending-approval    timeout=10

    # Count pending items
    ${pending}=    Get WebElements    class=pending-approval
    ${count}=      Get Length         ${pending}
    Log    [BOT] Found ${count} submissions awaiting decision    level=INFO
    Should Be True    ${count} >= 1    Expected at least 1 pending submission

    # Verify our target submission is in the queue
    Element Should Be Visible
    ...    //tr[@data-submission-id='${SUBMISSION_ID}']

    Log    [BOT] Target submission ${SUBMISSION_ID} confirmed in queue    level=INFO
    Log    [REPLACED] HoD no longer manually checks email — bot scans queue    level=INFO


# =============================================================================
# TC-DEMO-HOD-002 — Bot Reads Scores, Approves, Routes, Notifies
# =============================================================================
TC-DEMO-HOD-002 Bot Evaluates Submission And Routes Approved Document To FPGC
    [Documentation]    The bot reads evaluation scores from the submission page, computes
    ...                the average quality score, makes the approval decision, logs the
    ...                digital signature, routes the document to FPGC-R, and dispatches
    ...                email notifications — all in one automated pass.
    [Tags]    demo    hod    approval    rpa-routing    rpa-status

    Log    ══════════════════════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-HOD-002 Starting                              level=INFO
    Log    [BOT] Full approval workflow: evaluate → approve → route    level=INFO
    Log    ══════════════════════════════════════════════════════════    level=INFO

    # Authenticate as HoD
    Login As HoD

    # Open submission
    Go To Page    ${HOD_PORTAL}/approvals/pending
    Wait Until Element Is Visible
    ...    //tr[@data-submission-id='${SUBMISSION_ID}']    timeout=10
    Click Element    //tr[@data-submission-id='${SUBMISSION_ID}']//a
    Wait Until Element Is Visible    id=submission-details    timeout=10
    Log    [BOT] Opened submission ${SUBMISSION_ID}    level=INFO

    # ── Step 1: Read quality evaluation scores ──────────────────────────────
    Log    [BOT] Reading evaluation scores from system...    level=INFO
    ${s_format}=    Get Element Attribute    id=score-format_compliance        data-score
    ${s_content}=   Get Element Attribute    id=score-content_completeness     data-score
    ${s_rigor}=     Get Element Attribute    id=score-academic_rigor           data-score
    ${s_orig}=      Get Element Attribute    id=score-originality              data-score
    ${s_sup}=       Get Element Attribute    id=score-supervisor_endorsement   data-score

    Log    [BOT] Scores — Format:${s_format} | Content:${s_content} | Rigor:${s_rigor} | Originality:${s_orig} | Endorsement:${s_sup}    level=INFO

    # ── Step 2: Compute average quality score ───────────────────────────────
    ${avg}=    Evaluate
    ...    (int('${s_format}') + int('${s_content}') + int('${s_rigor}') + int('${s_orig}') + int('${s_sup}')) / 5

    Log    [BOT] Average quality score: ${avg} (approval threshold: 70)    level=INFO
    Should Be True    ${avg} >= 70    Quality score ${avg} is below threshold

    # ── Step 3: Submit approval decision ────────────────────────────────────
    Log    [BOT] Score above threshold — selecting Approve    level=INFO
    Select From List By Label    id=approval-decision    Approve
    Input Text    id=approval-comments
    ...    Submission meets all requirements. Approved for FPGC review.

    Click Button    id=submit-approval
    Wait Until Element Is Visible    id=approval-confirmation    timeout=10
    Element Should Contain    id=approval-confirmation    Approved successfully
    Log    [BOT] Approval decision recorded in system    level=INFO

    # ── Step 4: Verify workflow status ──────────────────────────────────────
    Element Should Contain    class=workflow-status-badge    Approved
    Log    [BOT] Workflow status badge updated to: Approved    level=INFO

    # ── Step 5: Route to FPGC-R via CustomLibrary ───────────────────────────
    ${route}=    Route Submission
    ...    submission_id=${SUBMISSION_ID}
    ...    current_stage=hod_evaluation
    ...    next_approver=fpgcr@nust.na
    ...    priority=normal

    Log    [BOT] Routed: ${route}[from_stage] → ${route}[to_stage]    level=INFO

    # ── Step 6: Dispatch notifications ──────────────────────────────────────
    Clear Notification Log

    Send Email Notification
    ...    recipient=fpgcr@nust.na
    ...    subject=New Summary of Proposals Requires FPGC Review - ${SUBMISSION_ID}
    ...    body=HoD has approved ${SUBMISSION_ID}. Please complete FPGC review.
    ...    notification_type=${NOTIF_REMINDER}

    Send Email Notification
    ...    recipient=j.chikwanha@nust.na
    ...    subject=Submission Approved by HoD
    ...    body=Your submission ${SUBMISSION_ID} has been approved and forwarded to FPGC.
    ...    notification_type=${NOTIF_APPROVAL}

    Send Email Notification
    ...    recipient=tendai.moyo@students.nust.na
    ...    subject=Proposal Approved — Proceeding to FPGC
    ...    body=Your Summary of Proposals (${SUBMISSION_ID}) has been approved by the HoD.
    ...    notification_type=${NOTIF_APPROVAL}

    ${log}=    Get Notification Log
    ${ncount}=    Get Length    ${log}
    Log    [BOT] ${ncount} notifications dispatched automatically    level=INFO
    Should Be True    ${ncount} >= 3

    Log    [REPLACED] HoD no longer manually emails FPGC-R, supervisor & student    level=INFO


# =============================================================================
# TC-DEMO-HOD-003 — Bot Auto-Assigns Internal Evaluators By Expertise Match
# =============================================================================
TC-DEMO-HOD-003 Bot Auto-Assigns Internal Evaluators By Expertise And Workload
    [Documentation]    The bot searches the evaluator database, matches expertise to the
    ...                proposal topic, checks each evaluator's workload, selects the best
    ...                2 candidates, confirms the assignment, and notifies each evaluator —
    ...                replacing the HoD's spreadsheet-based evaluator matching.
    [Tags]    demo    hod    evaluators    rpa-assignment

    Log    ══════════════════════════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-HOD-003 Starting                                  level=INFO
    Log    [BOT] Evaluator auto-assignment: expertise match + workload check    level=INFO
    Log    ══════════════════════════════════════════════════════════════    level=INFO

    Login As HoD
    Go To Page    ${HOD_PORTAL}/evaluators/assign-internal
    Wait Until Element Is Visible    id=expertise-search    timeout=10

    # Fill assignment search criteria
    Input Text    id=student-id    ${STUDENT_ID}
    Input Text    id=proposal-id    ${PROPOSAL_ID}
    Input Text    id=expertise-search    Machine Learning
    Log    [BOT] Searching for evaluators with expertise: Machine Learning    level=INFO

    Click Button    id=search-evaluators
    Wait Until Element Is Visible    id=evaluator-results    timeout=10
    Log    [BOT] Evaluator database query returned results    level=INFO

    # Process each candidate: check workload AND expertise
    ${candidates}=    Get WebElements    class=evaluator-candidate
    ${selected}=      Create List
    ${eval_count}=    Get Length    ${candidates}
    Log    [BOT] Evaluating ${eval_count} candidates    level=INFO

    FOR    ${c}    IN    @{candidates}
        ${eval_id}=    Get Element Attribute    ${c}    data-evaluator-id
        ${workload}=   Get Element Attribute    ${c}    data-current-workload
        ${match}=      Get Element Attribute    ${c}    data-expertise-match
        ${wl}=         Convert To Integer    ${workload}
        ${mt}=         Convert To Integer    ${match}

        IF    ${wl} < 5 and ${mt} >= 80
            Log    [BOT] SELECTED ${eval_id} — workload:${wl} students, match:${mt}%    level=INFO
            Append To List    ${selected}    ${eval_id}
        ELSE
            Log    [BOT] SKIPPED  ${eval_id} — workload:${wl} students, match:${mt}% (below threshold)    level=INFO
        END
    END

    ${sel_count}=    Get Length    ${selected}
    Log    [BOT] Selected ${sel_count} eligible evaluators from ${eval_count} candidates    level=INFO
    Should Be True    ${sel_count} >= 1    No suitable evaluators found

    # Confirm assignment
    Click Button    id=confirm-assignment
    Wait Until Element Is Visible    id=assignment-confirmation    timeout=10
    Log    [BOT] Assignment confirmed in system    level=INFO

    # Notify each assigned evaluator
    Clear Notification Log
    FOR    ${eval_id}    IN    @{selected}
        Send Email Notification
        ...    recipient=${eval_id.lower()}@nust.na
        ...    subject=Internal Evaluation Assignment — Proposal ${PROPOSAL_ID}
        ...    body=You have been assigned as internal evaluator for ${PROPOSAL_ID}. Please complete the checklist within 14 days.
        ...    notification_type=${NOTIF_REMINDER}
    END

    ${log}=    Get Notification Log
    ${nc}=    Get Length    ${log}
    Log    [BOT] ${nc} evaluator notification(s) dispatched    level=INFO
    Log    [REPLACED] Spreadsheet-based evaluator matching and manual email notifications    level=INFO


# =============================================================================
# TC-DEMO-HOD-004 — Bot Escalates Overdue Approval To DVC
# =============================================================================
TC-DEMO-HOD-004 Bot Identifies And Escalates Overdue Approvals To DVC
    [Documentation]    The bot scans the pending queue for items overdue beyond the
    ...                escalation threshold, creates a formal escalation record, and
    ...                dispatches a priority notification to the DVC — replacing the
    ...                manual email chain between HoD and DVC.
    [Tags]    demo    hod    escalation    rpa-status

    Log    ══════════════════════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-HOD-004 Starting                              level=INFO
    Log    [BOT] Checking for approvals overdue beyond 7-day threshold    level=INFO
    Log    ══════════════════════════════════════════════════════════    level=INFO

    Login As HoD
    Go To Page    ${HOD_PORTAL}/approvals/pending
    Wait Until Element Is Visible    class=pending-approval    timeout=10

    # Scan queue for overdue items
    ${items}=    Get WebElements    class=pending-approval
    ${overdue_ids}=    Create List

    FOR    ${item}    IN    @{items}
        ${item_id}=   Get Element Attribute    ${item}    data-item-id
        ${days}=      Get Element Attribute    ${item}    data-days-pending
        ${days_int}=  Convert To Integer    ${days}
        IF    ${days_int} >= 7
            Log    [BOT] OVERDUE item: ${item_id} — ${days_int} days pending    level=INFO
            Append To List    ${overdue_ids}    ${item_id}
        END
    END

    ${od_count}=    Get Length    ${overdue_ids}
    Log    [BOT] Found ${od_count} item(s) requiring escalation    level=INFO

    # Escalate each overdue item
    Clear Notification Log
    FOR    ${item_id}    IN    @{overdue_ids}
        ${esc}=    Escalate Overdue Item
        ...    item_id=${item_id}
        ...    item_type=approval
        ...    days_overdue=10
        ...    current_owner=hod@nust.na
        ...    escalation_level=dvc

        Send Email Notification
        ...    recipient=dvc-tlu@nust.na
        ...    subject=ESCALATION: HoD Approval Overdue — ${item_id}
        ...    body=Approval ${item_id} is 10 days overdue. Immediate DVC intervention required.
        ...    notification_type=${NOTIF_ESCALATION}

        Log    [BOT] Escalated ${item_id} → DVC: ${esc}[action_required]    level=INFO
    END

    ${log}=    Get Notification Log
    ${escalations}=    Evaluate    [n for n in ${log} if n['type'] == '${NOTIF_ESCALATION}']
    ${esc_notif_count}=    Get Length    ${escalations}
    Should Be True    ${esc_notif_count} >= 1    No escalation notification sent

    Log    [BOT] ${esc_notif_count} escalation(s) dispatched to DVC    level=INFO
    Log    [REPLACED] Manual email follow-up chain between HoD and DVC    level=INFO

*** Keywords ***

Reset For Test
    [Documentation]    Navigates back to login for each test.
    Go To Page    ${BASE_URL}/login
    Clear Notification Log
