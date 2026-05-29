*** Settings ***
Documentation       Cross-system and enterprise-level automation keywords for
...                 the NUST Postgraduate Digital System. Covers email &
...                 notification automation, reporting & analytics automation.
Library             SeleniumLibrary
Library             OperatingSystem
Library             DateTime
Library             Collections
Library             ../libraries/CustomLibrary.py
Resource            common_keywords.robot
Resource            ../variables/global_variables.robot

*** Keywords ***
# =============================================================================
# EMAIL & NOTIFICATION AUTOMATION
# =============================================================================

Send Centralized Notification
    [Documentation]    Centralized notification bot for approvals, rejections,
    ...                reminder alerts, deadline notifications, and oral defense scheduling.
    [Arguments]    ${recipient}    ${notification_type}    ${subject}    ${body}    ${priority}=normal

    Log Workflow Step    Sending ${notification_type} notification to ${recipient}

    # Log notification in centralized log
    ${timestamp}=    Get Current DateTime
    ${notification_id}=    Generate Unique ID    prefix=NOTIF

    # Send via email
    Send Email Notification
    ...    recipient=${recipient}
    ...    subject=${subject}
    ...    body=${body}
    ...    notification_type=${notification_type}

    # Log in system notification center
    Navigate To Page    ${BASE_URL}/admin/notifications
    Fill Input Field    id=notification-id    ${notification_id}
    Fill Input Field    id=recipient    ${recipient}
    Select Dropdown Option    id=notification-type    ${notification_type}
    Select Dropdown Option    id=priority    ${priority}
    Fill Input Field    id=subject    ${subject}
    Fill Input Field    id=content    ${body}
    Click Button    id=log-notification

    Log Workflow Step    Notification ${notification_id} sent and logged
    RETURN    ${notification_id}

Send Bulk Notifications
    [Documentation]    Sends bulk notifications to multiple recipients.
    [Arguments]    ${recipients}    ${notification_type}    ${template_name}    ${context_data}

    Log Workflow Step    Sending bulk ${notification_type} notifications to ${recipients} recipients

    ${sent_count}=    Set Variable    0

    FOR    ${recipient}    IN    @{recipients}
        # Generate personalized message from template
        ${subject}=    Generate From Template    ${template_name}    subject    ${context_data}
        ${body}=    Generate From Template    ${template_name}    body    ${context_data}

        Send Centralized Notification
        ...    recipient=${recipient}
        ...    notification_type=${notification_type}
        ...    subject=${subject}
        ...    body=${body}

        ${sent_count}=    Evaluate    ${sent_count} + 1
    END

    Log    Bulk notification complete: ${sent_count} sent    level=INFO
    RETURN    ${sent_count}

Generate From Template
    [Documentation]    Generates message content from a template with context data.
    [Arguments]    ${template_name}    ${part}    ${context_data}

    # Template definitions
    IF    '${template_name}' == 'submission_confirmation'
        IF    '${part}' == 'subject'
            RETURN    Submission Confirmation - ${context_data}[submission_type]
        ELSE
            RETURN    Your ${context_data}[submission_type] has been successfully submitted. Reference: ${context_data}[reference]. Status: ${context_data}[status].
        END
    ELSE IF    '${template_name}' == 'deadline_reminder'
        IF    '${part}' == 'subject'
            RETURN    Reminder: ${context_data}[item_type} Due Soon
        ELSE
            RETURN    This is a reminder that your ${context_data}[item_type] is due on ${context_data}[due_date]. ${context_data}[days_remaining] days remaining. Please submit promptly.
        END
    ELSE IF    '${template_name}' == 'approval_notification'
        IF    '${part}' == 'subject'
            RETURN    ${context_data}[item_type] ${context_data}[decision]
        ELSE
            RETURN    Your ${context_data}[item_type] has been ${context_data}[decision]. ${context_data}[feedback]
        END
    ELSE IF    '${template_name}' == 'oral_defense_scheduling'
        IF    '${part}' == 'subject'
            RETURN    Oral Defense Scheduled - ${context_data}[defense_date]
        ELSE
            RETURN    Your oral defense has been scheduled for ${context_data}[defense_date] at ${context_data}[defense_time]. Venue: ${context_data}[venue]. Panel: ${context_data}[panel_members].
        END
    ELSE
        RETURN    ${template_name} - ${part}
    END

Schedule Oral Defense
    [Documentation]    Automates oral defense scheduling with notifications.
    [Arguments]    ${student_id}    ${thesis_id}    ${proposed_dates}    ${panel_members}

    Log Workflow Step    Scheduling oral defense for ${student_id}

    Navigate To Page    ${BASE_URL}/admin/oral-defense/schedule

    Fill Input Field    id=student-id    ${student_id}
    Fill Input Field    id=thesis-id    ${thesis_id}

    # Select date from proposed options
    Select Dropdown Option    id=defense-date    ${proposed_dates}[0]
    Fill Input Field    id=defense-time    ${proposed_dates}[1]
    Fill Input Field    id=venue    ${proposed_dates}[2]

    # Assign panel members
    FOR    ${member}    IN    @{panel_members}
        Select Dropdown Option    id=panel-member    ${member}
        Click Button    id=add-panel-member
    END

    Click Button And Verify    id=confirm-schedule    id=schedule-confirmation

    ${defense_ref}=    Get Text    id=defense-reference

    # Notify all stakeholders
    ${student_email}=    Get Text    id=student-email
    ${supervisor_email}=    Get Text    id=supervisor-email

    ${context}=    Create Dictionary
    ...    defense_date=${proposed_dates}[0]
    ...    defense_time=${proposed_dates}[1]
    ...    venue=${proposed_dates}[2]
    ...    panel_members=${panel_members}

    Send Centralized Notification
    ...    recipient=${student_email}
    ...    notification_type=${NOTIF_REMINDER}
    ...    subject=Oral Defense Scheduled
    ...    body=Your oral defense has been scheduled. Reference: ${defense_ref}. Date: ${proposed_dates}[0] at ${proposed_dates}[1]. Venue: ${proposed_dates}[2].

    Send Centralized Notification
    ...    recipient=${supervisor_email}
    ...    notification_type=${NOTIF_REMINDER}
    ...    subject=Oral Defense Scheduled for Student ${student_id}
    ...    body=Oral defense for student ${student_id} scheduled. Reference: ${defense_ref}. Please confirm availability.

    # Notify panel members
    FOR    ${member}    IN    @{panel_members}
        ${member_email}=    Get Panel Member Email    ${member}
        Send Centralized Notification
        ...    recipient=${member_email}
        ...    notification_type=${NOTIF_REMINDER}
        ...    subject=Panel Assignment - Oral Defense ${defense_ref}
        ...    body=You have been assigned to an oral defense panel. Student: ${student_id}. Date: ${proposed_dates}[0]. Please confirm.
    END

    RETURN    ${defense_ref}

# =============================================================================
# REPORTING & ANALYTICS AUTOMATION
# =============================================================================

Generate Weekly Faculty Report
    [Documentation]    Scheduled bot that generates faculty reports every Friday
    ...                and emails committee members.
    [Arguments]    ${report_date}=${EMPTY}

    Log Workflow Step    Generating weekly faculty report

    Navigate To Page    ${BASE_URL}/admin/reports/weekly

    # Collect metrics
    ${total_students}=    Get Text    id=metric-total-students
    ${active_submissions}=    Get Text    id=metric-active-submissions
    ${overdue_submissions}=    Get Text    id=metric-overdue-submissions
    ${pending_reviews}=    Get Text    id=metric-pending-reviews
    ${completed_this_week}=    Get Text    id=metric-completed-this-week
    ${supervisor_workload_avg}=    Get Text    id=metric-supervisor-workload-avg

    ${report_data}=    Create Dictionary
    ...    total_students=${total_students}
    ...    active_submissions=${active_submissions}
    ...    overdue_submissions=${overdue_submissions}
    ...    pending_reviews=${pending_reviews}
    ...    completed_this_week=${completed_this_week}
    ...    supervisor_workload_avg=${supervisor_workload_avg}

    # Generate HTML report
    ${report_path}=    Generate Faculty Report
    ...    report_data=${report_data}
    ...    report_type=weekly
    ...    output_path=${REPORT_DIR}/weekly_faculty_report_${report_date}.html

    # Generate CSV data export
    ${csv_path}=    Set Variable    ${REPORT_DIR}/weekly_faculty_report_${report_date}.csv
    Generate CSV Report    ${report_data}    ${csv_path}

    # Email to committee members
    ${committee_emails}=    Get Committee Emails
    FOR    ${email}    IN    @{committee_emails}
        Send Centralized Notification
        ...    recipient=${email}
        ...    notification_type=${NOTIF_REMINDER}
        ...    subject=Weekly Faculty Report - ${report_date}
        ...    body=Please find attached the weekly faculty report. Overdue submissions: ${overdue_submissions}. Pending reviews: ${pending_reviews}.
    END

    # Archive report
    Archive Report    ${report_path}    ${REPORT_DIR}/archive/
    Archive Report    ${csv_path}    ${REPORT_DIR}/archive/

    Log Workflow Step    Weekly report generated and distributed
    RETURN    ${report_path}

Generate Completion Statistics Report
    [Documentation]    Generates completion statistics for postgraduate programs.
    [Arguments]    ${period}=monthly    ${program}=all

    Log Workflow Step    Generating ${period} completion statistics for ${program}

    Navigate To Page    ${BASE_URL}/admin/reports/completion-stats

    Select Dropdown Option    id=report-period    ${period}
    Select Dropdown Option    id=program-filter    ${program}
    Click Button    id=generate-report

    Wait Until Element Is Visible    id=completion-stats-results

    ${total_enrolled}=    Get Text    id=stat-total-enrolled
    ${completed}=    Get Text    id=stat-completed
    ${in_progress}=    Get Text    id=stat-in-progress
    ${withdrawn}=    Get Text    id=stat-withdrawn
    ${avg_completion_time}=    Get Text    id=stat-avg-completion-time
    ${completion_rate}=    Get Text    id=stat-completion-rate

    ${stats}=    Create Dictionary
    ...    total_enrolled=${total_enrolled}
    ...    completed=${completed}
    ...    in_progress=${in_progress}
    ...    withdrawn=${withdrawn}
    ...    avg_completion_time=${avg_completion_time}
    ...    completion_rate=${completion_rate}

    ${report_path}=    Generate Faculty Report
    ...    report_data=${stats}
    ...    report_type=${period}_completion
    ...    output_path=${REPORT_DIR}/${period}_completion_stats.html

    RETURN    ${stats}    ${report_path}

Generate Supervisor Workload Report
    [Documentation]    Generates supervisor workload distribution report.
    [Arguments]    ${department}=all

    Log Workflow Step    Generating supervisor workload report for ${department}

    Navigate To Page    ${BASE_URL}/admin/reports/supervisor-workload

    Select Dropdown Option    id=department-filter    ${department}
    Click Button    id=generate-workload-report

    Wait Until Element Is Visible    id=workload-report-results

    ${supervisor_data}=    Create List
    ${rows}=    Get WebElements    class=supervisor-workload-row

    FOR    ${row}    IN    @{rows}
        ${sup_id}=    Get Element Attribute    ${row}    data-supervisor-id
        ${sup_name}=    Get Element Attribute    ${row}    data-name
        ${student_count}=    Get Element Attribute    ${row}    data-students
        ${active_reviews}=    Get Element Attribute    ${row}    data-active-reviews
        ${overdue_reviews}=    Get Element Attribute    ${row}    data-overdue-reviews

        ${data}=    Create Dictionary
        ...    supervisor_id=${sup_id}
        ...    name=${sup_name}
        ...    students=${student_count}
        ...    active_reviews=${active_reviews}
        ...    overdue_reviews=${overdue_reviews}

        Append To List    ${supervisor_data}    ${data}
    END

    ${report_path}=    Generate Faculty Report
    ...    report_data=${supervisor_data}
    ...    report_type=supervisor_workload
    ...    output_path=${REPORT_DIR}/supervisor_workload_${department}.html

    RETURN    ${supervisor_data}    ${report_path}

Generate Overdue Submission Report
    [Documentation]    Generates report of all overdue submissions for escalation.
    [Arguments]    ${escalation_level}=all

    Log Workflow Step    Generating overdue submission report (level: ${escalation_level})

    Navigate To Page    ${BASE_URL}/admin/reports/overdue

    Select Dropdown Option    id=escalation-filter    ${escalation_level}
    Click Button    id=generate-overdue-report

    Wait Until Element Is Visible    id=overdue-report-results

    ${overdue_items}=    Create List
    ${rows}=    Get WebElements    class=overdue-item

    FOR    ${row}    IN    @{rows}
        ${student_id}=    Get Element Attribute    ${row}    data-student-id
        ${student_name}=    Get Element Attribute    ${row}    data-student-name
        ${submission_type}=    Get Element Attribute    ${row}    data-type
        ${due_date}=    Get Element Attribute    ${row}    data-due-date
        ${supervisor}=    Get Element Attribute    ${row}    data-supervisor
        ${last_action}=    Get Element Attribute    ${row}    data-last-action

        ${record}=    Create Dictionary
        ...    student_id=${student_id}
        ...    student_name=${student_name}
        ...    submission_type=${submission_type}
        ...    due_date=${due_date}
        ...    supervisor=${supervisor}
        ...    last_action=${last_action}

        Append To List    ${overdue_items}    ${record}
    END

    ${report_path}=    Generate Overdue Submission Report
    ...    overdue_data=${overdue_items}
    ...    output_path=${REPORT_DIR}/overdue_submissions_${escalation_level}.csv

    # Send to relevant authorities
    IF    '${escalation_level}' == 'high'
        ${dvc_email}=    Set Variable    dvc-tlu@nust.na
        Send Centralized Notification
        ...    recipient=${dvc_email}
        ...    notification_type=${NOTIF_ESCALATION}
        ...    subject=HIGH PRIORITY: Overdue Submissions Report
        ...    body=High priority overdue submissions report attached. Immediate action required for ${len(${overdue_items})} items.
    END

    RETURN    ${overdue_items}    ${report_path}

Generate CSV Report
    [Documentation]    Generates a CSV export of report data.
    [Arguments]    ${data}    ${output_path}

    ${csv_content}=    Evaluate    ','.join(${data}.keys()) + '\n' + ','.join(str(v) for v in ${data}.values())
    Create File    ${output_path}    ${csv_content}

Archive Report
    [Documentation]    Archives a report to the archive directory.
    [Arguments]    ${file_path}    ${archive_dir}

    ${filename}=    Evaluate    os.path.basename('${file_path}')    modules=os
    ${archive_path}=    Set Variable    ${archive_dir}/${filename}

    Copy File    ${file_path}    ${archive_path}
    Log    Report archived: ${archive_path}    level=INFO

# =============================================================================
# HELPER KEYWORDS
# =============================================================================

Get Committee Emails
    [Documentation]    Retrieves FPGC and HDC committee member emails.
    Navigate To Page    ${BASE_URL}/admin/committee/contacts
    ${emails}=    Get WebElements    class=committee-email
    ${email_list}=    Create List
    FOR    ${email}    IN    @{emails}
        ${text}=    Get Text    ${email}
        Append To List    ${email_list}    ${text}
    END
    RETURN    ${email_list}

Get Panel Member Email
    [Documentation]    Retrieves panel member email.
    [Arguments]    ${member_id}
    Navigate To Page    ${EVALUATOR_PORTAL}/${member_id}/contact
    ${email}=    Get Text    id=member-email
    RETURN    ${email}
