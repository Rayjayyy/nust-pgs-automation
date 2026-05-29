*** Settings ***
Documentation       Keywords for Head of Department (HoD) Module automation.
...                 Covers approval workflow automation, evaluator assignment,
...                 and external evaluator proposals.
Library             SeleniumLibrary
Library             OperatingSystem
Library             DateTime
Library             Collections
Library             ../libraries/CustomLibrary.py
Resource            common_keywords.robot
Resource            ../variables/global_variables.robot

*** Keywords ***
# =============================================================================
# APPROVAL WORKFLOW AUTOMATION
# =============================================================================

Automate Approval Workflow
    [Documentation]    Bot manages workflow routing, status tracking, approval
    ...                reminders, and escalation handling for HoD approvals.
    [Arguments]    ${submission_id}    ${submission_type}    ${priority}=normal

    Log Workflow Step    HoD approval workflow initiated for ${submission_id}

    Navigate To Page    ${HOD_PORTAL}/approvals/pending

    # Find and open submission
    ${submission_row}=    Set Variable    //tr[@data-submission-id='${submission_id}']
    Click Element    ${submission_row}
    Wait For Page Load

    # Review submission details
    Element Should Be Visible    id=submission-details
    Element Should Be Visible    id=supervisor-comments
    Element Should Be Visible    id=student-record

    # Evaluate and make decision
    ${decision}=    Evaluate Submission Quality    ${submission_id}

    IF    ${decision}[quality_score] >= 70
        Approve Submission    ${submission_id}    ${submission_type}    ${priority}
    ELSE IF    ${decision}[quality_score] >= 50
        Request Revision    ${submission_id}    ${decision}[feedback]
    ELSE
        Reject Submission    ${submission_id}    ${decision}[feedback]
    END

    Log Workflow Step    Approval workflow completed for ${submission_id}

Evaluate Submission Quality
    [Documentation]    Evaluates submission quality based on checklist criteria.
    [Arguments]    ${submission_id}

    ${criteria}=    Create List
    ...    format_compliance
    ...    content_completeness
    ...    academic_rigor
    ...    originality
    ...    supervisor_endorsement

    ${scores}=    Create List
    FOR    ${criterion}    IN    @{criteria}
        ${score}=    Get Element Attribute    id=score-${criterion}    data-score
        ${score_int}=    Convert To Integer    ${score}
        Append To List    ${scores}    ${score_int}
    END

    ${total}=    Evaluate    sum(${scores})
    ${avg}=    Evaluate    ${total} / len(${scores})

    ${feedback}=    Get Text    id=evaluation-feedback

    RETURN    ${avg}    ${feedback}

Approve Submission
    [Documentation]    Approves a submission and routes to FPGC-R.
    [Arguments]    ${submission_id}    ${submission_type}    ${priority}

    Log Workflow Step    Approving submission ${submission_id}

    Select Dropdown Option    id=approval-decision    Approve
    Fill Input Field    id=approval-comments    Submission meets all requirements. Approved for FPGC review.
    Upload File    id=digital-signature    ${DATA_DIR}/hod_signature.png

    Click Button And Verify    id=submit-approval    id=approval-confirmation

    Verify Element Contains Text    id=approval-confirmation    Approved successfully

    # Update workflow status
    Verify Workflow Status    ${STATUS_APPROVED}

    # Route to FPGC-R
    ${route_result}=    Route Submission
    ...    submission_id=${submission_id}
    ...    current_stage=hod_evaluation
    ...    next_approver=${FPGC-R_ID}
    ...    priority=${priority}

    # Notify FPGC-R
    ${fpgc_email}=    Get Text    id=fpgc-r-email
    Send Email Notification
    ...    recipient=${fpgc_email}
    ...    subject=New ${submission_type} Requires FPGC Review - ${submission_id}
    ...    body=HoD has approved ${submission_type} (${submission_id}) and routed it for FPGC review. Please evaluate.
    ...    notification_type=${NOTIF_REMINDER}

    # Notify supervisor
    ${supervisor_email}=    Get Text    id=supervisor-email
    Send Email Notification
    ...    recipient=${supervisor_email}
    ...    subject=${submission_type} Approved by HoD
    ...    body=Your submission ${submission_id} has been approved by the HoD and forwarded to FPGC for review.
    ...    notification_type=${NOTIF_APPROVAL}

    Log Workflow Step    Submission ${submission_id} approved and routed to FPGC-R

Request Revision
    [Documentation]    Requests revision for a submission that needs improvement.
    [Arguments]    ${submission_id}    ${feedback}

    Log Workflow Step    Requesting revision for ${submission_id}

    Select Dropdown Option    id=approval-decision    Request Revision
    Fill Input Field    id=revision-feedback    ${feedback}
    Fill Input Field    id=revision-deadline    ${REVISION_DEADLINE}

    Click Button And Verify    id=submit-revision-request    id=revision-confirmation

    Verify Workflow Status    ${STATUS_PENDING}

    # Notify student and supervisor
    ${student_email}=    Get Text    id=student-email
    ${supervisor_email}=    Get Text    id=supervisor-email

    Send Email Notification
    ...    recipient=${student_email}
    ...    subject=Revision Required for Submission ${submission_id}
    ...    body=Your submission requires revision. Feedback: ${feedback}. Deadline: ${REVISION_DEADLINE}
    ...    notification_type=${NOTIF_REMINDER}

    Send Email Notification
    ...    recipient=${supervisor_email}
    ...    subject=Student Submission Requires Revision - ${submission_id}
    ...    body=Student submission ${submission_id} requires revision. Please guide the student.
    ...    notification_type=${NOTIF_REMINDER}

Reject Submission
    [Documentation]    Rejects a submission with detailed feedback.
    [Arguments]    ${submission_id}    ${feedback}

    Log Workflow Step    Rejecting submission ${submission_id}

    Select Dropdown Option    id=approval-decision    Reject
    Fill Input Field    id=rejection-reason    ${feedback}

    Click Button And Verify    id=submit-rejection    id=rejection-confirmation

    Verify Workflow Status    ${STATUS_REJECTED}

    # Notify student and supervisor
    ${student_email}=    Get Text    id=student-email
    ${supervisor_email}=    Get Text    id=supervisor-email

    Send Email Notification
    ...    recipient=${student_email}
    ...    subject=Submission ${submission_id} Rejected
    ...    body=Your submission has been rejected. Reason: ${feedback}. Please consult your supervisor.
    ...    notification_type=${NOTIF_REJECTION}

    Send Email Notification
    ...    recipient=${supervisor_email}
    ...    subject=Student Submission Rejected - ${submission_id}
    ...    body=Student submission ${submission_id} has been rejected. Please review with student.
    ...    notification_type=${NOTIF_REJECTION}

# =============================================================================
# INTERNAL EVALUATOR ASSIGNMENT
# =============================================================================

Assign Internal Evaluators
    [Documentation]    HoD assigns internal evaluators to student proposals.
    ...                Bot checks evaluator availability, expertise match, and workload.
    [Arguments]    ${student_id}    ${proposal_id}    ${required_expertise}

    Log Workflow Step    Assigning internal evaluators for proposal ${proposal_id}

    Navigate To Page    ${HOD_PORTAL}/evaluators/assign-internal

    Fill Input Field    id=student-id    ${student_id}
    Fill Input Field    id=proposal-id    ${proposal_id}

    # Search for available evaluators with matching expertise
    Fill Input Field    id=expertise-search    ${required_expertise}
    Click Button    id=search-evaluators

    Wait Until Element Is Visible    id=evaluator-results    timeout=${MEDIUM_WAIT}

    # Get evaluator candidates
    ${evaluators}=    Get WebElements    class=evaluator-candidate
    ${selected}=    Create List
    ${evaluator_count}=    Set Variable    0

    FOR    ${evaluator}    IN    @{evaluators}
        ${eval_id}=    Get Element Attribute    ${evaluator}    data-evaluator-id
        ${workload}=    Get Element Attribute    ${evaluator}    data-current-workload
        ${expertise_match}=    Get Element Attribute    ${evaluator}    data-expertise-match

        ${workload_int}=    Convert To Integer    ${workload}
        ${match_int}=    Convert To Integer    ${expertise_match}

        # Select if workload acceptable and expertise matches
        IF    ${workload_int} < 5 and ${match_int} >= 80
            Click Element    ${evaluator}
            Append To List    ${selected}    ${eval_id}
            ${evaluator_count}=    Evaluate    ${evaluator_count} + 1
        END

        # Stop when we have 2 evaluators
        IF    ${evaluator_count} == 2
            Exit For Loop
        END
    END

    Should Be True    ${evaluator_count} >= 1    Could not find suitable internal evaluators

    # Assign selected evaluators
    Click Button And Verify    id=confirm-assignment    id=assignment-confirmation

    # Notify evaluators
    FOR    ${eval_id}    IN    @{selected}
        ${eval_email}=    Get Evaluator Email    ${eval_id}
        Send Email Notification
        ...    recipient=${eval_email}
        ...    subject=Internal Evaluation Assignment - Proposal ${proposal_id}
        ...    body=You have been assigned as an internal evaluator for proposal ${proposal_id}. Please review and sign the checklist.
        ...    notification_type=${NOTIF_REMINDER}
    END

    Log Workflow Step    ${evaluator_count} internal evaluators assigned for ${proposal_id}
    RETURN    ${selected}

# =============================================================================
# EXTERNAL EVALUATOR PROPOSAL
# =============================================================================

Propose External Evaluators
    [Documentation]    HoD proposes external evaluators for thesis examination.
    ...                Updates profile for easy visibility.
    [Arguments]    ${student_id}    ${thesis_id}    ${expertise_area}

    Log Workflow Step    Proposing external evaluators for thesis ${thesis_id}

    Navigate To Page    ${HOD_PORTAL}/evaluators/propose-external

    Fill Input Field    id=student-id    ${student_id}
    Fill Input Field    id=thesis-id    ${thesis_id}
    Fill Input Field    id=expertise-area    ${expertise_area}

    # Search external evaluator database
    Click Button    id=search-external
    Wait Until Element Is Visible    id=external-evaluator-results

    # Select top 3 candidates
    ${candidates}=    Get WebElements    class=external-candidate
    ${proposed}=    Create List
    ${count}=    Set Variable    0

    FOR    ${candidate}    IN    @{candidates}
        ${eval_id}=    Get Element Attribute    ${candidate}    data-evaluator-id
        ${profile_complete}=    Get Element Attribute    ${candidate}    data-profile-complete

        IF    '${profile_complete}' == 'true'
            Click Element    ${candidate}
            Append To List    ${proposed}    ${eval_id}
            ${count}=    Evaluate    ${count} + 1
        END

        IF    ${count} == 3
            Exit For Loop
        END
    END

    Should Be True    ${count} >= 2    Could not find enough external evaluators

    # Submit proposal to FPGC
    Click Button And Verify    id=submit-proposal    id=proposal-confirmation

    ${proposal_ref}=    Get Text    id=proposal-reference

    # Route to FPGC for approval
    Route Submission
    ...    submission_id=${proposal_ref}
    ...    current_stage=hod_evaluation
    ...    next_approver=${FPGC-R_ID}
    ...    priority=normal

    # Notify FPGC
    ${fpgc_email}=    Get Text    id=fpgc-r-email
    Send Email Notification
    ...    recipient=${fpgc_email}
    ...    subject=External Evaluator Proposal - Thesis ${thesis_id}
    ...    body=HoD has proposed ${count} external evaluators for thesis ${thesis_id}. Reference: ${proposal_ref}. Please review.
    ...    notification_type=${NOTIF_REMINDER}

    Log Workflow Step    ${count} external evaluators proposed for ${thesis_id}
    RETURN    ${proposed}    ${proposal_ref}

# =============================================================================
# APPROVAL REMINDER & ESCALATION
# =============================================================================

Send Approval Reminders
    [Documentation]    Sends reminders for pending HoD approvals.
    [Arguments]    ${days_pending}=3

    Log Workflow Step    Sending approval reminders for items pending ${days_pending}+ days

    Navigate To Page    ${HOD_PORTAL}/approvals/pending

    ${pending_items}=    Get WebElements    class=pending-approval

    FOR    ${item}    IN    @{pending_items}
        ${item_id}=    Get Element Attribute    ${item}    data-item-id
        ${days}=    Get Element Attribute    ${item}    data-days-pending
        ${days_int}=    Convert To Integer    ${days}

        IF    ${days_int} >= ${days_pending}
            Log    Reminder: Item ${item_id} pending ${days} days
            # System auto-generates reminder - verify notification sent
            Verify Notification Sent    ${HOD_ID}@nust.na    ${NOTIF_REMINDER}
        END
    END

Handle Escalation
    [Documentation]    Handles escalation for severely overdue approvals.
    [Arguments]    ${item_id}    ${days_overdue}

    Log Workflow Step    Handling escalation for ${item_id} (${days_overdue} days overdue)

    ${escalation}=    Escalate Overdue Item
    ...    item_id=${item_id}
    ...    item_type=approval
    ...    days_overdue=${days_overdue}
    ...    current_owner=${HOD_ID}
    ...    escalation_level=dvc

    Send Email Notification
    ...    recipient=dvc-tlu@nust.na
    ...    subject=ESCALATION: HoD Approval Overdue - ${item_id}
    ...    body=Approval ${item_id} is ${days_overdue} days overdue. HoD intervention required.
    ...    notification_type=${NOTIF_ESCALATION}

# =============================================================================
# HELPER KEYWORDS
# =============================================================================

Get Evaluator Email
    [Documentation]    Retrieves evaluator email from system.
    [Arguments]    ${evaluator_id}
    Navigate To Page    ${EVALUATOR_PORTAL}/${evaluator_id}/profile
    ${email}=    Get Text    id=evaluator-email
    RETURN    ${email}
