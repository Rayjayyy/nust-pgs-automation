"""
Custom Library for NUST Postgraduate Digital System Automation
Provides advanced utilities for workflow automation, reporting, and data processing.
"""

import os
import csv
import json
import random
import smtplib
import logging
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from pathlib import Path

from robot.api.deco import keyword
from robot.api import logger


class CustomLibrary:
    """Custom Robot Framework library for NUST PG System RPA."""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '1.0.0'

    def __init__(self):
        self.notification_log = []
        self.workflow_log = []
        self.report_data = []

    # =========================================================================
    # WORKFLOW AUTOMATION KEYWORDS
    # =========================================================================

    @keyword("Validate Document Upload")
    def validate_document_upload(self, file_path, allowed_extensions=None, max_size_mb=10):
        """Validates a document upload meets requirements.

        Args:
            file_path: Path to the uploaded file
            allowed_extensions: List of allowed file extensions (default: ['pdf', 'docx'])
            max_size_mb: Maximum file size in MB

        Returns:
            dict: Validation result with status and details
        """
        if allowed_extensions is None:
            allowed_extensions = ['pdf', 'docx', 'doc']

        result = {
            'valid': True,
            'errors': [],
            'warnings': []
        }

        # Check file exists
        if not os.path.exists(file_path):
            result['valid'] = False
            result['errors'].append("File does not exist")
            return result

        # Check extension
        ext = os.path.splitext(file_path)[1].lower().replace('.', '')
        if ext not in allowed_extensions:
            result['valid'] = False
            result['errors'].append(f"Invalid file type: .{ext}. Allowed: {', '.join(allowed_extensions)}")

        # Check file size
        size_mb = os.path.getsize(file_path) / (1024 * 1024)
        if size_mb > max_size_mb:
            result['valid'] = False
            result['errors'].append(f"File too large: {size_mb:.2f}MB (max {max_size_mb}MB)")
        elif size_mb == 0:
            result['valid'] = False
            result['errors'].append("File is empty")

        # Check for corruption (basic)
        try:
            with open(file_path, 'rb') as f:
                header = f.read(8)
                if len(header) < 8:
                    result['valid'] = False
                    result['errors'].append("File appears to be corrupted")
        except Exception as e:
            result['valid'] = False
            result['errors'].append(f"Cannot read file: {str(e)}")

        logger.info(f"Document validation result: {result['valid']}")
        return result

    @keyword("Check Submission Completeness")
    def check_submission_completeness(self, required_fields, submitted_data):
        """Checks if all required fields are present in submission.

        Args:
            required_fields: List of required field names
            submitted_data: Dictionary of submitted data

        Returns:
            dict: Completeness check result
        """
        missing = []
        empty = []

        for field in required_fields:
            if field not in submitted_data:
                missing.append(field)
            elif submitted_data[field] in [None, '', 'null', 'undefined']:
                empty.append(field)

        result = {
            'complete': len(missing) == 0 and len(empty) == 0,
            'missing_fields': missing,
            'empty_fields': empty,
            'completion_percentage': round(
                ((len(required_fields) - len(missing) - len(empty)) / len(required_fields)) * 100, 2
            )
        }

        logger.info(f"Submission completeness: {result['completion_percentage']}%")
        return result

    @keyword("Verify Deadline")
    def verify_deadline(self, deadline_str, current_date_str=None):
        """Verifies if a deadline has been met.

        Args:
            deadline_str: Deadline in YYYY-MM-DD format
            current_date_str: Current date (default: today)

        Returns:
            dict: Deadline status information
        """
        deadline = datetime.strptime(deadline_str, '%Y-%m-%d')

        if current_date_str:
            current = datetime.strptime(current_date_str, '%Y-%m-%d')
        else:
            current = datetime.now()

        days_remaining = (deadline - current).days

        result = {
            'deadline': deadline_str,
            'current_date': current.strftime('%Y-%m-%d'),
            'days_remaining': days_remaining,
            'is_overdue': days_remaining < 0,
            'is_due_soon': 0 <= days_remaining <= 3,
            'status': 'overdue' if days_remaining < 0 else 'due_soon' if days_remaining <= 3 else 'on_track'
        }

        logger.info(f"Deadline status: {result['status']} ({days_remaining} days remaining)")
        return result

    @keyword("Calculate Supervisor Workload")
    def calculate_supervisor_workload(self, supervisor_data):
        """Calculates workload metrics for supervisors.

        Args:
            supervisor_data: List of dicts with supervisor assignments

        Returns:
            dict: Workload analysis with recommendations
        """
        workloads = {}

        for entry in supervisor_data:
            sup_id = entry.get('supervisor_id')
            if sup_id not in workloads:
                workloads[sup_id] = {
                    'supervisor_name': entry.get('supervisor_name', 'Unknown'),
                    'total_students': 0,
                    'active_reviews': 0,
                    'overdue_reviews': 0,
                    'pending_approvals': 0
                }

            workloads[sup_id]['total_students'] += 1
            if entry.get('review_status') == 'pending':
                workloads[sup_id]['active_reviews'] += 1
            if entry.get('review_status') == 'overdue':
                workloads[sup_id]['overdue_reviews'] += 1
            if entry.get('approval_status') == 'pending':
                workloads[sup_id]['pending_approvals'] += 1

        # Calculate averages and flag overloaded
        avg_students = sum(w['total_students'] for w in workloads.values()) / len(workloads) if workloads else 0

        for sup_id, data in workloads.items():
            data['workload_score'] = (
                data['total_students'] * 1 +
                data['active_reviews'] * 2 +
                data['overdue_reviews'] * 3 +
                data['pending_approvals'] * 1.5
            )
            data['is_overloaded'] = data['workload_score'] > (avg_students * 3)
            data['recommendation'] = (
                'REDISTRIBUTE' if data['is_overloaded'] 
                else 'ACCEPT_NEW' if data['workload_score'] < avg_students 
                else 'MONITOR'
            )

        logger.info(f"Workload calculated for {len(workloads)} supervisors")
        return {
            'supervisors': workloads,
            'average_workload': round(avg_students, 2),
            'overloaded_count': sum(1 for w in workloads.values() if w['is_overloaded'])
        }

    # =========================================================================
    # REPORTING & ANALYTICS KEYWORDS
    # =========================================================================

    @keyword("Generate Faculty Report")
    def generate_faculty_report(self, report_data, report_type="weekly", output_path=None):
        """Generates a faculty report from collected data.

        Args:
            report_data: Dictionary containing report metrics
            report_type: Type of report (weekly, monthly, adhoc)
            output_path: Path to save the report

        Returns:
            str: Path to generated report
        """
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

        if not output_path:
            output_path = f"reports/faculty_report_{report_type}_{timestamp}.html"

        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        # Generate HTML report
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>NUST Faculty Report - {report_type.upper()}</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 40px; }}
                h1 {{ color: #003366; }}
                table {{ border-collapse: collapse; width: 100%; margin: 20px 0; }}
                th, td {{ border: 1px solid #ddd; padding: 12px; text-align: left; }}
                th {{ background-color: #003366; color: white; }}
                tr:nth-child(even) {{ background-color: #f2f2f2; }}
                .metric {{ font-size: 24px; font-weight: bold; color: #003366; }}
                .overdue {{ color: #cc0000; }}
                .on-track {{ color: #009900; }}
            </style>
        </head>
        <body>
            <h1>NUST Postgraduate Faculty Report</h1>
            <p><strong>Report Type:</strong> {report_type.upper()}</p>
            <p><strong>Generated:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
            <hr>

            <h2>Key Metrics</h2>
            <table>
                <tr>
                    <th>Metric</th>
                    <th>Value</th>
                    <th>Status</th>
                </tr>
        """

        for key, value in report_data.items():
            status_class = 'overdue' if 'overdue' in str(key).lower() and value > 0 else 'on-track'
            html_content += f"""
                <tr>
                    <td>{key.replace('_', ' ').title()}</td>
                    <td class="metric">{value}</td>
                    <td class="{status_class}">{'Attention Needed' if status_class == 'overdue' else 'On Track'}</td>
                </tr>
            """

        html_content += """
            </table>
            <footer>
                <p><em>Generated by NUST PG System RPA Bot</em></p>
            </footer>
        </body>
        </html>
        """

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_content)

        logger.info(f"Report generated: {output_path}")
        return output_path

    @keyword("Generate Overdue Submission Report")
    def generate_overdue_submission_report(self, overdue_data, output_path=None):
        """Generates a report of overdue submissions for escalation.

        Args:
            overdue_data: List of overdue submission records
            output_path: Path to save the report

        Returns:
            str: Path to generated report
        """
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

        if not output_path:
            output_path = f"reports/overdue_report_{timestamp}.csv"

        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        with open(output_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow([
                'Student ID', 'Student Name', 'Submission Type', 
                'Due Date', 'Days Overdue', 'Supervisor', 
                'Last Action', 'Escalation Level'
            ])

            for record in overdue_data:
                days_overdue = (datetime.now() - datetime.strptime(record['due_date'], '%Y-%m-%d')).days
                escalation = 'HIGH' if days_overdue > 14 else 'MEDIUM' if days_overdue > 7 else 'LOW'

                writer.writerow([
                    record.get('student_id', 'N/A'),
                    record.get('student_name', 'N/A'),
                    record.get('submission_type', 'N/A'),
                    record['due_date'],
                    days_overdue,
                    record.get('supervisor', 'N/A'),
                    record.get('last_action', 'None'),
                    escalation
                ])

        logger.info(f"Overdue report generated: {output_path} with {len(overdue_data)} records")
        return output_path

    # =========================================================================
    # NOTIFICATION & COMMUNICATION KEYWORDS
    # =========================================================================

    @keyword("Send Email Notification")
    def send_email_notification(self, recipient, subject, body, notification_type="general"):
        """Sends an email notification (simulated for testing).

        Args:
            recipient: Email recipient address
            subject: Email subject
            body: Email body content
            notification_type: Type of notification for logging

        Returns:
            bool: True if notification logged successfully
        """
        notification = {
            'timestamp': datetime.now().isoformat(),
            'recipient': recipient,
            'subject': subject,
            'type': notification_type,
            'status': 'sent'
        }

        self.notification_log.append(notification)

        logger.info(f"[{notification_type}] Notification sent to {recipient}: {subject}")
        return True

    @keyword("Get Notification Log")
    def get_notification_log(self):
        """Returns the notification log for verification."""
        return self.notification_log

    @keyword("Clear Notification Log")
    def clear_notification_log(self):
        """Clears the notification log."""
        self.notification_log = []
        logger.info("Notification log cleared")

    # =========================================================================
    # WORKFLOW ORCHESTRATION KEYWORDS
    # =========================================================================

    @keyword("Route Submission")
    def route_submission(self, submission_id, current_stage, next_approver, priority="normal"):
        """Routes a submission to the next approver in the workflow.

        Args:
            submission_id: Unique submission identifier
            current_stage: Current workflow stage
            next_approver: ID of the next approver
            priority: Submission priority (low, normal, high, urgent)

        Returns:
            dict: Routing result with new stage and timestamp
        """
        route_record = {
            'submission_id': submission_id,
            'from_stage': current_stage,
            'to_stage': self._get_next_stage(current_stage),
            'next_approver': next_approver,
            'priority': priority,
            'routed_at': datetime.now().isoformat(),
            'status': 'routed'
        }

        self.workflow_log.append(route_record)

        logger.info(
            f"Submission {submission_id} routed from {current_stage} "
            f"to {route_record['to_stage']} -> {next_approver}"
        )
        return route_record

    def _get_next_stage(self, current_stage):
        """Determines the next workflow stage."""
        stages = {
            'student_submitted': 'supervisor_review',
            'supervisor_review': 'hod_evaluation',
            'hod_evaluation': 'fpgc_review',
            'fpgc_review': 'hdc_approval',
            'hdc_approval': 'completed'
        }
        return stages.get(current_stage, 'unknown')

    @keyword("Escalate Overdue Item")
    def escalate_overdue_item(self, item_id, item_type, days_overdue, current_owner, escalation_level):
        """Escalates an overdue item to higher authority.

        Args:
            item_id: Identifier of the overdue item
            item_type: Type of item (submission, review, approval)
            days_overdue: Number of days overdue
            current_owner: Current responsible person
            escalation_level: Level to escalate to (hod, dvc, committee)

        Returns:
            dict: Escalation record
        """
        escalation = {
            'item_id': item_id,
            'item_type': item_type,
            'days_overdue': days_overdue,
            'from': current_owner,
            'to': escalation_level,
            'escalated_at': datetime.now().isoformat(),
            'action_required': f"Immediate action required for {item_type} overdue by {days_overdue} days"
        }

        logger.warn(f"ESCALATION: {item_id} -> {escalation_level} ({days_overdue} days overdue)")
        return escalation

    # =========================================================================
    # DATA GENERATION & MOCKING KEYWORDS
    # =========================================================================

    @keyword("Generate Mock Student Data")
    def generate_mock_student_data(self, count=5):
        """Generates mock student data for testing."""
        programs = ['MSc Computer Science', 'PhD Information Systems', 'MEng Software Engineering', 'PhD Data Science']
        statuses = ['Active', 'Pending', 'Suspended', 'Completed']

        students = []
        for i in range(count):
            student = {
                'student_id': f'PG2026{str(i+1).zfill(3)}',
                'name': f'Student {i+1}',
                'email': f'student{i+1}@nust.na',
                'program': random.choice(programs),
                'enrollment_date': (datetime.now() - timedelta(days=random.randint(30, 365))).strftime('%Y-%m-%d'),
                'status': random.choice(statuses),
                'supervisor_id': f'SUP2026{str(random.randint(1, 5)).zfill(3)}',
                'progress_percentage': random.randint(0, 100)
            }
            students.append(student)

        return students

    @keyword("Generate Mock Submission Data")
    def generate_mock_submission_data(self, count=10):
        """Generates mock submission data for testing workflows."""
        types = ['Progress Report', 'Table of Changes', 'Summary of Proposals', 'Thesis', 'Checklist']
        statuses = ['Pending', 'Under Review', 'Approved', 'Rejected', 'Overdue']

        submissions = []
        for i in range(count):
            due_date = datetime.now() + timedelta(days=random.randint(-14, 14))
            submission = {
                'submission_id': f'SUB2026{str(i+1).zfill(4)}',
                'student_id': f'PG2026{str(random.randint(1, 50)).zfill(3)}',
                'type': random.choice(types),
                'status': random.choice(statuses),
                'submitted_date': (datetime.now() - timedelta(days=random.randint(0, 30))).strftime('%Y-%m-%d'),
                'due_date': due_date.strftime('%Y-%m-%d'),
                'supervisor_id': f'SUP2026{str(random.randint(1, 10)).zfill(3)}',
                'review_status': random.choice(['Pending', 'In Progress', 'Completed']),
                'approval_status': random.choice(['Pending', 'Approved', 'Rejected'])
            }
            submissions.append(submission)

        return submissions
