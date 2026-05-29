*** Settings ***
Documentation       Keywords for Student Module automation in the NUST
...                 Postgraduate Digital System. Covers progress report submission,
...                 progress monitoring, and application workflows.
Library             SeleniumLibrary
Library             OperatingSystem
Library             DateTime
Library             ../libraries/CustomLibrary.py
Resource            common_keywords.robot
Resource            ../variables/global_variables.robot

*** Keywords ***
# =============================================================================
# PROGRESS REPORT SUBMISSION AUTOMATION
# =============================================================================

Student Uploads Progress Report
    [Documentation]    Automates the complete progress report submission workflow.
    ...                Validates document, checks completeness, updates status,
    ...                sends confirmation, and alerts supervisor.
    [Arguments]    ${student_id}    ${file_path}    ${report_period}

    Log Workflow Step    Student ${student_id} initiating progress report upload

    # Step 1: Validate document
    ${validation}=    Validate Document Upload    ${file_path}    max_size_mb=15
    Should Be True    ${validation}[valid]    Document validation failed: ${validation}[errors]
    Log Workflow Step    Document validation passed

    # Step 2: Navigate to upload page
    Navigate To Page    ${STUDENT_PORTAL}/progress-report/upload

    # Step 3: Fill submission form
    Fill Input Field    id=student-id    ${student_id}
    Fill Input Field    id=report-period    ${report_period}
    Select Dropdown Option    id=report-type    ${DOC_PROGRESS_REPORT}

    # Step 4: Upload document
    Upload File    id=document-upload    ${file_path}

    # Step 5: Check submission completeness
    ${required_fields}=    Create List    student_id    report_period    report_type    document
    ${submitted_data}=    Create Dictionary
    ...    student_id=${student_id}
    ...    report_period=${report_period}
    ...    report_type=${DOC_PROGRESS_REPORT}
    ...    document=${file_path}

    ${completeness}=    Check Submission Completeness    ${required_fields}    ${submitted_data}
    Should Be True    ${completeness}[complete]    Submission incomplete: ${completeness}[missing_fields]
    Log Workflow Step    Submission completeness: ${completeness}[completion_percentage]%

    # Step 6: Submit and verify
    Click Button And Verify    id=submit-report    id=confirmation-message
    Verify Element Contains Text    id=confirmation-message    Progress Report submitted successfully

    # Step 7: Update workflow status
    Verify Workflow Status    ${STATUS_UNDER_REVIEW}
    Log Workflow Step    Workflow status updated to Under Review

    # Step 8: Send confirmation notification
    ${timestamp}=    Get Current DateTime
    Send Email Notification
    ...    recipient=${student_id}@nust.na
    ...    subject=Progress Report Submitted - ${timestamp}
    ...    body=Your progress report for ${report_period} has been submitted successfully and is now under review.
    ...    notification_type=${NOTIF_CONFIRMATION}

    # Step 9: Alert supervisor
    ${supervisor_email}=    Get Supervisor Email    ${student_id}
    Send Email Notification
    ...    recipient=${supervisor_email}
    ...    subject=New Progress Report Requires Review - Student ${student_id}
    ...    body=A new progress report from student ${student_id} for ${report_period} requires your review.
    ...    notification_type=${NOTIF_REMINDER}

    Log Workflow Step    Progress report submission workflow completed for ${student_id}

Student Uploads Table Of Changes
    [Documentation]    Automates Table of Changes submission workflow.
    [Arguments]    ${student_id}    ${file_path}    ${thesis_version}

    Log Workflow Step    Student ${student_id} initiating Table of Changes upload

    ${validation}=    Validate Document Upload    ${file_path}    allowed_extensions=['pdf', 'docx']
    Should Be True    ${validation}[valid]

    Navigate To Page    ${STUDENT_PORTAL}/table-of-changes/upload
    Fill Input Field    id=student-id    ${student_id}
    Fill Input Field    id=thesis-version    ${thesis_version}
    Select Dropdown Option    id=document-type    ${DOC_TABLE_OF_CHANGES}
    Upload File    id=document-upload    ${file_path}

    Click Button And Verify    id=submit-changes    id=confirmation-message
    Verify Element Contains Text    id=confirmation-message    Table of Changes submitted successfully

    Verify Workflow Status    ${STATUS_UNDER_REVIEW}

    Send Email Notification
    ...    recipient=${student_id}@nust.na
    ...    subject=Table of Changes Submitted
    ...    body=Your Table of Changes for thesis version ${thesis_version} has been submitted.
    ...    notification_type=${NOTIF_CONFIRMATION}

    Log Workflow Step    Table of Changes submission completed

# =============================================================================
# STUDENT PROGRESS MONITORING AUTOMATION
# =============================================================================

Check Individual Student Progress
    [Documentation]    Retrieves and verifies individual student progress dashboard.
    [Arguments]    ${student_id}

    Log Workflow Step    Checking progress for student ${student_id}

    Navigate To Page    ${STUDENT_PORTAL}/progress/${student_id}

    # Verify progress components are visible
    Wait Until Element Is Visible    id=progress-overview    timeout=${MEDIUM_WAIT}
    Element Should Be Visible    id=milestone-timeline
    Element Should Be Visible    id=supervisor-feedback-section
    Element Should Be Visible    id=hdc-feedback-section

    # Extract progress metrics
    ${progress_pct}=    Get Text    id=overall-progress-percentage
    ${current_stage}=    Get Text    id=current-stage
    ${next_deadline}=    Get Text    id=next-deadline

    Log    Student ${student_id} progress: ${progress_pct} at stage ${current_stage}

    # Verify deadline status
    ${deadline_status}=    Verify Deadline    ${next_deadline}
    IF    ${deadline_status}[is_overdue]
        Log    WARNING: Student ${student_id} has overdue deadline!    level=WARN
        Send Email Notification
        ...    recipient=${student_id}@nust.na
        ...    subject=URGENT: Overdue Submission Detected
        ...    body=Your submission deadline (${next_deadline}) has passed. Please take immediate action.
        ...    notification_type=${NOTIF_ESCALATION}
    ELSE IF    ${deadline_status}[is_due_soon]
        Log    Student ${student_id} deadline approaching: ${deadline_status}[days_remaining] days    level=INFO
        Send Email Notification
        ...    recipient=${student_id}@nust.na
        ...    subject=Reminder: Submission Due Soon
        ...    body=Your submission is due in ${deadline_status}[days_remaining] days (${next_deadline}).
        ...    notification_type=${NOTIF_REMINDER}
    END

    RETURN    ${progress_pct}    ${current_stage}    ${deadline_status}

Scan For Overdue Student Submissions
    [Documentation]    Daily scheduled scan to identify overdue submissions across all students.
    ...                Sends reminders and escalates severe delays.
    [Arguments]    ${scan_date}=${EMPTY}

    Log Workflow Step    Starting daily overdue submission scan

    Navigate To Page    ${STUDENT_PORTAL}/admin/overdue-scan

    # Trigger scan
    Click Button And Verify    id=start-scan    id=scan-results

    # Extract overdue items
    ${overdue_count}=    Get Text    id=overdue-count
    Log    Overdue submissions found: ${overdue_count}

    IF    '${overdue_count}' != '0'
        # Process each overdue item
        ${overdue_items}=    Get WebElements    class=overdue-item
        FOR    ${item}    IN    @{overdue_items}
            ${student_id}=    Get Element Attribute    ${item}    data-student-id
            ${days_overdue}=    Get Element Attribute    ${item}    data-days-overdue
            ${submission_type}=    Get Element Attribute    ${item}    data-submission-type

            Log    Processing overdue: ${student_id} - ${submission_type} (${days_overdue} days)

            # Send reminder after 3 days
            IF    ${days_overdue} >= ${REMINDER_DAYS}
                Send Email Notification
                ...    recipient=${student_id}@nust.na
                ...    subject=Reminder: ${submission_type} Overdue by ${days_overdue} Days
                ...    body=Your ${submission_type} is ${days_overdue} days overdue. Please submit immediately.
                ...    notification_type=${NOTIF_REMINDER}
            END

            # Escalate after 7 days
            IF    ${days_overdue} >= ${ESCALATION_DAYS}
                ${supervisor_email}=    Get Supervisor Email    ${student_id}
                Send Email Notification
                ...    recipient=${supervisor_email}
                ...    subject=ESCALATION: Student ${student_id} ${submission_type} Severely Overdue
                ...    body=Student ${student_id}'s ${submission_type} is ${days_overdue} days overdue. Intervention required.
                ...    notification_type=${NOTIF_ESCALATION}

                # Escalate to HoD if > 14 days
                IF    ${days_overdue} >= 14
                    ${escalation}=    Escalate Overdue Item
                    ...    item_id=${student_id}_${submission_type}
                    ...    item_type=${submission_type}
                    ...    days_overdue=${days_overdue}
                    ...    current_owner=${supervisor_email}
                    ...    escalation_level=hod
                    Log    Escalated to HoD: ${escalation}    level=WARN
                END
            END
        END
    ELSE
        Log    No overdue submissions found - all students on track    level=INFO
    END

    Log Workflow Step    Daily scan completed. Overdue items processed.

Identify Inactive Students
    [Documentation]    Identifies students with no recent activity and sends alerts.
    [Arguments]    ${inactivity_threshold_days}=30

    Log Workflow Step    Scanning for inactive students (threshold: ${inactivity_threshold_days} days)

    Navigate To Page    ${STUDENT_PORTAL}/admin/inactive-students

    Click Button And Verify    id=identify-inactive    id=inactive-results

    ${inactive_count}=    Get Text    id=inactive-count
    IF    '${inactive_count}' != '0'
        ${inactive_students}=    Get WebElements    class=inactive-student
        FOR    ${student}    IN    @{inactive_students}
            ${student_id}=    Get Element Attribute    ${student}    data-student-id
            ${last_activity}=    Get Element Attribute    ${student}    data-last-activity
            ${supervisor}=    Get Element Attribute    ${student}    data-supervisor

            Send Email Notification
            ...    recipient=${student_id}@nust.na
            ...    subject=Activity Alert: No Recent Progress Detected
            ...    body=No activity detected for ${inactivity_threshold_days} days. Last activity: ${last_activity}. Please update your progress.
            ...    notification_type=${NOTIF_REMINDER}

            Send Email Notification
            ...    recipient=${supervisor}
            ...    subject=Student ${student_id} Inactivity Alert
            ...    body=Your student ${student_id} has shown no activity for ${inactivity_threshold_days} days.
            ...    notification_type=${NOTIF_REMINDER}
        END
    END

# =============================================================================
# POSTGRADUATE APPLICATION AUTOMATION
# =============================================================================

Submit Postgraduate Application
    [Documentation]    Automates prospective student application submission.
    [Arguments]    ${applicant_data}

    Log Workflow Step    New postgraduate application submission

    Navigate To Page    ${BASE_URL}/apply

    # Fill personal information
    Fill Input Field    id=first-name    ${applicant_data}[first_name]
    Fill Input Field    id=last-name    ${applicant_data}[last_name]
    Fill Input Field    id=email    ${applicant_data}[email]
    Fill Input Field    id=phone    ${applicant_data}[phone]

    # Academic background
    Select Dropdown Option    id=highest-qualification    ${applicant_data}[qualification]
    Fill Input Field    id=institution    ${applicant_data}[institution]
    Fill Input Field    id=qualification-year    ${applicant_data}[year]

    # Program selection
    Select Dropdown Option    id=program-choice-1    ${applicant_data}[program_choice_1]
    Select Dropdown Option    id=program-choice-2    ${applicant_data}[program_choice_2]

    # Upload supporting documents
    Upload File    id=id-document    ${applicant_data}[id_document]
    Upload File    id=academic-transcript    ${applicant_data}[transcript]
    Upload File    id=cv-document    ${applicant_data}[cv]

    # Submit application
    Click Button And Verify    id=submit-application    id=application-reference

    ${reference}=    Get Text    id=application-reference
    Log    Application submitted with reference: ${reference}

    Send Email Notification
    ...    recipient=${applicant_data}[email]
    ...    subject=Application Received - Reference ${reference}
    ...    body=Your postgraduate application has been received. Reference: ${reference}. We will review and update you.
    ...    notification_type=${NOTIF_CONFIRMATION}

    RETURN    ${reference}

# =============================================================================
# HELPER KEYWORDS
# =============================================================================

Get Supervisor Email
    [Documentation]    Retrieves supervisor email from student record.
    [Arguments]    ${student_id}
    Navigate To Page    ${STUDENT_PORTAL}/student/${student_id}/supervisor
    ${email}=    Get Text    id=supervisor-email
    RETURN    ${email}
