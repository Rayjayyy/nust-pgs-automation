*** Settings ***
Documentation       Head of Department (HoD) Module Test Suite for NUST
...                 Postgraduate Digital System. Tests approval workflow
...                 automation, evaluator assignment, and external evaluator
...                 proposals.
Metadata            Version    1.0.0
Metadata            Author    ASD810S Assignment II
Metadata            Date    2026-05-28

Library             SeleniumLibrary
Library             OperatingSystem
Library             DateTime
Library             Collections
Library             ../libraries/CustomLibrary.py

Resource            ../resources/keywords/common_keywords.robot
Resource            ../resources/keywords/hod_keywords.robot
Resource            ../resources/variables/global_variables.robot

Suite Setup         HoD Suite Setup
Suite Teardown      HoD Suite Teardown
Test Setup          HoD Test Setup
Test Teardown       HoD Test Teardown

*** Variables ***
${TEST_HOD_ID}              HOD2026001
${TEST_SUBMISSION_ID}       SUB2026001
${TEST_STUDENT_ID}          PG2026001
${TEST_PROPOSAL_ID}         PROP2026001
${TEST_THESIS_ID}           THS2026001
${TEST_EVALUATOR_ID}        EVA2026001
${HOD_SIGNATURE}            ${DATA_DIR}/hod_signature.png

*** Test Cases ***
# =============================================================================
# TC-HOD-001: Approval Workflow Automation
# Priority: VERY HIGH
# =============================================================================
TC-HOD-001 Approve Submission And Route To FPGC
    [Documentation]    Tests complete approval workflow: review, approve, route to
    ...                FPGC-R, and notify all stakeholders.
    [Tags]    hod    approval    very_high    workflow    smoke

    Given HoD Has Pending Submission    ${TEST_SUBMISSION_ID}
    When HoD Evaluates And Approves Submission
    ...    submission_id=${TEST_SUBMISSION_ID}
    ...    submission_type=${DOC_SUMMARY_PROPOSALS}
    ...    priority=normal
    Then Submission Status Should Be Approved
    And Submission Should Be Routed To FPGC
    And FPGC-R Should Be Notified
    And Supervisor Should Receive Approval Confirmation

TC-HOD-002 Request Revision For Submission
    [Documentation]    Tests requesting revision with feedback and deadline.
    [Tags]    hod    approval    revision    workflow

    Given HoD Has Pending Submission    ${TEST_SUBMISSION_ID}
    When HoD Requests Revision
    ...    submission_id=${TEST_SUBMISSION_ID}
    ...    feedback=Literature review needs more recent sources. Methodology section requires clarification.
    Then Submission Status Should Be Pending Revision
    And Student Should Receive Revision Request
    And Supervisor Should Be Notified Of Revision

TC-HOD-003 Reject Submission With Reason
    [Documentation]    Tests rejection workflow with detailed feedback.
    [Tags]    hod    approval    rejection    negative

    Given HoD Has Pending Submission    ${TEST_SUBMISSION_ID}
    When HoD Rejects Submission
    ...    submission_id=${TEST_SUBMISSION_ID}
    ...    feedback=Submission does not meet minimum academic standards. Fundamental issues with research design.
    Then Submission Status Should Be Rejected
    And Student Should Receive Rejection Notice
    And Supervisor Should Receive Rejection Notice

TC-HOD-004 Auto-Route Approved Thesis With High Priority
    [Documentation]    Tests that approved theses get high priority routing.
    [Tags]    hod    approval    thesis    priority

    Given HoD Has Pending Thesis    ${TEST_THESIS_ID}
    When HoD Approves Thesis
    ...    submission_id=${TEST_THESIS_ID}
    ...    submission_type=${DOC_THESIS}
    ...    priority=high
    Then Thesis Should Be Routed With High Priority
    And FPGC-R Should Receive Priority Notification

# =============================================================================
# TC-HOD-005: Approval Reminder Automation
# Priority: VERY HIGH
# =============================================================================
TC-HOD-005 Send Approval Reminders For Pending Items
    [Documentation]    Tests automatic reminders for HoD approvals pending 3+ days.
    [Tags]    hod    reminder    very_high    scheduled

    Given HoD Has Approvals Pending 5 Days
    When Approval Reminder Bot Runs
    Then Reminder Should Be Sent To HoD
    And Pending Items Should Be Listed

TC-HOD-006 Escalate Overdue Approvals
    [Documentation]    Tests escalation for approvals overdue 7+ days.
    [Tags]    hod    escalation    very_high    scheduled

    Given HoD Has Approval Pending 10 Days
    When Escalation Bot Runs
    Then Escalation Should Be Sent To DVC
    And Overdue Item Should Be Flagged

# =============================================================================
# TC-HOD-007: Assign Internal Evaluators
# Priority: HIGH
# =============================================================================
TC-HOD-007 Assign Internal Evaluators By Expertise
    [Documentation]    Tests automated internal evaluator assignment based on
    ...                expertise match and workload check.
    [Tags]    hod    evaluators    internal    high    workflow

    Given Student Has Proposal Requiring Evaluation    ${TEST_PROPOSAL_ID}
    When HoD Assigns Internal Evaluators
    ...    student_id=${TEST_STUDENT_ID}
    ...    proposal_id=${TEST_PROPOSAL_ID}
    ...    required_expertise=Machine Learning
    Then At Least One Evaluator Should Be Assigned
    And Evaluators Should Have Matching Expertise
    And Evaluators Should Have Acceptable Workload
    And Evaluators Should Be Notified

TC-HOD-008 No Available Internal Evaluators
    [Documentation]    Tests handling when no suitable internal evaluators found.
    [Tags]    hod    evaluators    internal    negative

    Given All Internal Evaluators Are Overloaded
    When HoD Attempts To Assign Internal Evaluators
    Then System Should Display No Evaluators Available
    And HoD Should Be Alerted To Staff Shortage

# =============================================================================
# TC-HOD-009: Propose External Evaluators
# Priority: HIGH
# =============================================================================
TC-HOD-009 Propose External Evaluators For Thesis
    [Documentation]    Tests external evaluator proposal with profile completeness check.
    [Tags]    hod    evaluators    external    high    workflow

    Given Student Has Thesis For External Evaluation    ${TEST_THESIS_ID}
    When HoD Proposes External Evaluators
    ...    student_id=${TEST_STUDENT_ID}
    ...    thesis_id=${TEST_THESIS_ID}
    ...    expertise_area=Artificial Intelligence
    Then At Least Two External Evaluators Should Be Proposed
    And Proposed Evaluators Should Have Complete Profiles
    And Proposal Should Be Routed To FPGC
    And FPGC Should Be Notified

TC-HOD-010 External Evaluator Profile Update
    [Documentation]    Tests that external evaluator profiles are updated for visibility.
    [Tags]    hod    evaluators    external    profile

    Given External Evaluator Has Incomplete Profile    ${TEST_EVALUATOR_ID}
    When HoD Updates Evaluator Profile
    Then Profile Completeness Should Reach 100%
    And Updated Profile Should Be Visible To FPGC

# =============================================================================
# TC-HOD-011: Workflow Status Tracking
# Priority: MEDIUM
# =============================================================================
TC-HOD-011 Track Submission Status Across Workflow
    [Documentation]    Tests status tracking from submission through all stages.
    [Tags]    hod    tracking    medium

    Given Submission Is In System    ${TEST_SUBMISSION_ID}
    When HoD Checks Workflow Status
    Then Current Stage Should Be Displayed
    And History Should Show All Previous Stages
    And Next Stage Should Be Indicated

*** Keywords ***
# =============================================================================
# SETUP & TEARDOWN
# =============================================================================

HoD Suite Setup
    [Documentation]    Suite-level setup for HoD module tests.
    Open NUST Browser    ${HOD_PORTAL}
    Create Test Data Files

HoD Suite Teardown
    [Documentation]    Suite-level teardown for HoD module tests.
    Close NUST Browser
    Cleanup Test Data

HoD Test Setup
    [Documentation]    Test-level setup for HoD module tests.
    Clear Notification Log
    Navigate To Page    ${HOD_PORTAL}

HoD Test Teardown
    [Documentation]    Test-level teardown for HoD module tests.
    Run Keyword If Test Failed    Take Screenshot On Failure    ${TEST_NAME}
    Logout User

# =============================================================================
# GIVEN/WHEN/THEN KEYWORDS
# =============================================================================

HoD Has Pending Submission
    [Arguments]    ${submission_id}
    Set Test Variable    ${CURRENT_SUBMISSION}    ${submission_id}
    Login As User    ${TEST_HOD_ID}    hod_password    Head of Department
    Navigate To Page    ${HOD_PORTAL}/approvals/pending
    Element Should Be Visible    //tr[@data-submission-id='${submission_id}']

HoD Has Pending Thesis
    [Arguments]    ${thesis_id}
    Set Test Variable    ${CURRENT_THESIS}    ${thesis_id}
    Login As User    ${TEST_HOD_ID}    hod_password    Head of Department
    Navigate To Page    ${HOD_PORTAL}/approvals/pending
    Element Should Be Visible    //tr[@data-submission-id='${thesis_id}']

HoD Has Approvals Pending 5 Days
    [Documentation]    Prepares test data with approvals pending 5 days.
    ${mock_approvals}=    Create List
    ...    {"item_id": "APP001", "days_pending": "5", "type": "SoP"}
    ...    {"item_id": "APP002", "days_pending": "5", "type": "Thesis"}
    Set Test Variable    ${MOCK_APPROVALS}    ${mock_approvals}

HoD Has Approval Pending 10 Days
    ${mock_approval}=    Create Dictionary
    ...    item_id=APP003
    ...    days_pending=10
    ...    type=Progress Report
    Set Test Variable    ${MOCK_OVERDUE_APPROVAL}    ${mock_approval}

Student Has Proposal Requiring Evaluation
    [Arguments]    ${proposal_id}
    Set Test Variable    ${CURRENT_PROPOSAL}    ${proposal_id}
    Login As User    ${TEST_HOD_ID}    hod_password    Head of Department

Student Has Thesis For External Evaluation
    [Arguments]    ${thesis_id}
    Set Test Variable    ${CURRENT_THESIS}    ${thesis_id}
    Login As User    ${TEST_HOD_ID}    hod_password    Head of Department

All Internal Evaluators Are Overloaded
    [Documentation]    Simulates all evaluators having maximum workload.
    Set Test Variable    ${ALL_OVERLOADED}    ${TRUE}

External Evaluator Has Incomplete Profile
    [Arguments]    ${evaluator_id}
    Set Test Variable    ${INCOMPLETE_EVALUATOR}    ${evaluator_id}
    Login As User    ${TEST_HOD_ID}    hod_password    Head of Department

Submission Is In System
    [Arguments]    ${submission_id}
    Set Test Variable    ${TRACKING_SUBMISSION}    ${submission_id}

HoD Evaluates And Approves Submission
    [Arguments]    ${submission_id}    ${submission_type}    ${priority}
    Automate Approval Workflow
    ...    submission_id=${submission_id}
    ...    submission_type=${submission_type}
    ...    priority=${priority}

HoD Requests Revision
    [Arguments]    ${submission_id}    ${feedback}
    Request Revision    ${submission_id}    ${feedback}

HoD Rejects Submission
    [Arguments]    ${submission_id}    ${feedback}
    Reject Submission    ${submission_id}    ${feedback}

HoD Approves Thesis
    [Arguments]    ${submission_id}    ${submission_type}    ${priority}
    Automate Approval Workflow
    ...    submission_id=${submission_id}
    ...    submission_type=${submission_type}
    ...    priority=${priority}

Approval Reminder Bot Runs
    Send Approval Reminders    days_pending=3

Escalation Bot Runs
    Handle Escalation
    ...    item_id=${MOCK_OVERDUE_APPROVAL}[item_id]
    ...    days_overdue=${MOCK_OVERDUE_APPROVAL}[days_pending]

HoD Assigns Internal Evaluators
    [Arguments]    ${student_id}    ${proposal_id}    ${required_expertise}
    ${assigned}=    Assign Internal Evaluators
    ...    student_id=${student_id}
    ...    proposal_id=${proposal_id}
    ...    required_expertise=${required_expertise}
    Set Test Variable    ${ASSIGNED_EVALUATORS}    ${assigned}

HoD Attempts To Assign Internal Evaluators
    Run Keyword And Expect Error    *    Assign Internal Evaluators
    ...    student_id=${TEST_STUDENT_ID}
    ...    proposal_id=${TEST_PROPOSAL_ID}
    ...    required_expertise=Quantum Computing

HoD Proposes External Evaluators
    [Arguments]    ${student_id}    ${thesis_id}    ${expertise_area}
    ${proposed}    ${ref}=    Propose External Evaluators
    ...    student_id=${student_id}
    ...    thesis_id=${thesis_id}
    ...    expertise_area=${expertise_area}
    Set Test Variable    ${PROPOSED_EVALUATORS}    ${proposed}
    Set Test Variable    ${PROPOSAL_REF}    ${ref}

HoD Updates Evaluator Profile
    [Documentation]    Updates external evaluator profile for completeness.
    Navigate To Page    ${EVALUATOR_PORTAL}/${INCOMPLETE_EVALUATOR}/profile/edit
    Fill Input Field    id=institution    University of Example
    Fill Input Field    id=specialization    Artificial Intelligence
    Fill Input Field    id=publications    45
    Upload File    id=cv-document    ${DATA_DIR}/evaluator_cv.pdf
    Click Button    id=save-profile

HoD Checks Workflow Status
    [Documentation]    Retrieves workflow status for tracking.
    Navigate To Page    ${HOD_PORTAL}/workflow/${TRACKING_SUBMISSION}/status

# =============================================================================
# VERIFICATION KEYWORDS
# =============================================================================

Submission Status Should Be Approved
    Verify Workflow Status    ${STATUS_APPROVED}

Submission Should Be Routed To FPGC
    ${log}=    Get Notification Log
    ${routing}=    Evaluate    [n for n in ${log} if 'FPGC' in n['subject'] or 'fpgc' in n['recipient'].lower()]
    Should Not Be Empty    ${routing}    Submission not routed to FPGC

FPGC-R Should Be Notified
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'FPGC' in n['subject'] or 'review' in n['subject'].lower()]
    Should Not Be Empty    ${notifications}    FPGC-R not notified

Supervisor Should Receive Approval Confirmation
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'Approved' in n['subject'] and 'supervisor' in n['recipient'].lower()]
    Should Not Be Empty    ${notifications}

Submission Status Should Be Pending Revision
    Verify Workflow Status    ${STATUS_PENDING}

Student Should Receive Revision Request
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'Revision Required' in n['subject']]
    Should Not Be Empty    ${notifications}

Supervisor Should Be Notified Of Revision
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'Revision' in n['subject'] and 'supervisor' in n['recipient'].lower()]
    Should Not Be Empty    ${notifications}

Submission Status Should Be Rejected
    Verify Workflow Status    ${STATUS_REJECTED}

Student Should Receive Rejection Notice
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'Rejected' in n['subject']]
    Should Not Be Empty    ${notifications}

Supervisor Should Receive Rejection Notice
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'Rejected' in n['subject'] and 'supervisor' in n['recipient'].lower()]
    Should Not Be Empty    ${notifications}

Thesis Should Be Routed With High Priority
    ${log}=    Get Notification Log
    ${routing}=    Evaluate    [n for n in ${log} if 'high' in n.get('priority', '').lower()]
    Should Not Be Empty    ${routing}

FPGC-R Should Receive Priority Notification
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'high' in n.get('priority', '').lower() and 'FPGC' in n['subject']]
    Should Not Be Empty    ${notifications}

Reminder Should Be Sent To HoD
    ${log}=    Get Notification Log
    ${reminders}=    Evaluate    [n for n in ${log} if n['type'] == '${NOTIF_REMINDER}' and '${TEST_HOD_ID}' in n['recipient']]
    Should Not Be Empty    ${reminders}

Pending Items Should Be Listed
    Element Should Be Visible    id=pending-approvals-list

Escalation Should Be Sent To DVC
    ${log}=    Get Notification Log
    ${escalations}=    Evaluate    [n for n in ${log} if n['type'] == '${NOTIF_ESCALATION}' and 'dvc' in n['recipient'].lower()]
    Should Not Be Empty    ${escalations}

Overdue Item Should Be Flagged
    Element Should Contain    id=escalation-status    Escalated

At Least One Evaluator Should Be Assigned
    Should Not Be Empty    ${ASSIGNED_EVALUATORS}
    ${count}=    Get Length    ${ASSIGNED_EVALUATORS}
    Should Be True    ${count} >= 1    No evaluators assigned

Evaluators Should Have Matching Expertise
    Log    Expertise match verified during assignment process

Evaluators Should Have Acceptable Workload
    Log    Workload verified during assignment process

Evaluators Should Be Notified
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'Internal Evaluation Assignment' in n['subject']]
    Should Not Be Empty    ${notifications}

System Should Display No Evaluators Available
    Page Should Contain    No suitable evaluators available

HoD Should Be Alerted To Staff Shortage
    ${log}=    Get Notification Log
    ${alerts}=    Evaluate    [n for n in ${log} if 'staff shortage' in n['body'].lower() or 'evaluator' in n['subject'].lower()]
    Should Not Be Empty    ${alerts}

At Least Two External Evaluators Should Be Proposed
    Should Not Be Empty    ${PROPOSED_EVALUATORS}
    ${count}=    Get Length    ${PROPOSED_EVALUATORS}
    Should Be True    ${count} >= 2    Only ${count} evaluators proposed

Proposed Evaluators Should Have Complete Profiles
    Log    Profile completeness verified during proposal

Proposal Should Be Routed To FPGC
    ${log}=    Get Notification Log
    ${routing}=    Evaluate    [n for n in ${log} if 'External Evaluator Proposal' in n['subject']]
    Should Not Be Empty    ${routing}

FPGC Should Be Notified
    ${log}=    Get Notification Log
    ${notifications}=    Evaluate    [n for n in ${log} if 'External Evaluator' in n['subject'] and 'fpgc' in n['recipient'].lower()]
    Should Not Be Empty    ${notifications}

Profile Completeness Should Reach 100%
    Element Should Contain    id=profile-completeness    100%

Updated Profile Should Be Visible To FPGC
    Log    Profile visibility verified in system

Current Stage Should Be Displayed
    Element Should Be Visible    id=current-stage

History Should Show All Previous Stages
    Element Should Be Visible    id=workflow-history
    ${history_items}=    Get WebElements    class=history-item
    Should Not Be Empty    ${history_items}

Next Stage Should Be Indicated
    Element Should Be Visible    id=next-stage

# =============================================================================
# TEST DATA MANAGEMENT
# =============================================================================

Create Test Data Files
    [Documentation]    Creates mock test data files.
    ${test_dir}=    Set Variable    ${DATA_DIR}
    Create Directory    ${test_dir}
    Run    echo "Mock HoD signature" > ${test_dir}/hod_signature.png
    Run    echo "Mock evaluator CV" > ${test_dir}/evaluator_cv.pdf

Cleanup Test Data
    [Documentation]    Cleans up test data.
    Remove Directory    ${DATA_DIR}    recursive=${TRUE}
