"""
NUST PGS Demo Mock Server
Flask application that simulates the NUST Postgraduate Digital System.
Serves HTML pages with the exact element IDs expected by the RPA keyword libraries.
"""

from flask import Flask, request, session, redirect
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'nust-pgs-demo-2026'

# ---------------------------------------------------------------------------
# Service account credentials (matches README.md)
# ---------------------------------------------------------------------------
USERS = {
    'hod@nust.na':                      {'password': 'password', 'role': 'Head of Department'},
    'HOD2026001':                       {'password': 'hod_password', 'role': 'Head of Department'},
    'tendai.moyo@students.nust.na':     {'password': 'password', 'role': 'Student'},
    'j.chikwanha@nust.na':             {'password': 'password', 'role': 'Supervisor'},
    'fpgcr@nust.na':                    {'password': 'password', 'role': 'FPGC Representative'},
    'fpgc@nust.na':                     {'password': 'password', 'role': 'FPGC Member'},
    'e.kamati@nust.na':                 {'password': 'password', 'role': 'Internal Evaluator'},
    'external@nust.na':                 {'password': 'password', 'role': 'External Evaluator'},
}


# ---------------------------------------------------------------------------
# HTML helper — wraps body in a consistent layout
# ---------------------------------------------------------------------------
def page(title, body, role=None, show_nav=True):
    nav = ''
    if show_nav and role:
        nav = f'''
        <nav style="background:#003366;color:white;padding:12px 28px;
                    display:flex;justify-content:space-between;align-items:center;">
            <span style="font-size:18px;font-weight:bold;">
                NUST Postgraduate Digital System
            </span>
            <span>
                <span id="user-role-badge"
                      style="background:#0055cc;padding:6px 16px;border-radius:20px;font-size:13px;">
                    {role}
                </span>
                &nbsp;
                <a href="/logout" id="logout-button"
                   style="color:white;background:#cc3300;padding:6px 16px;
                          border-radius:4px;text-decoration:none;font-size:13px;">
                    Logout
                </a>
            </span>
        </nav>'''

    return f'''<!DOCTYPE html>
<html>
<head>
    <title>{title} — NUST PGS</title>
    <meta charset="UTF-8">
    <style>
        body  {{font-family:Arial,sans-serif;margin:0;background:#f0f4f8;}}
        .wrap {{max-width:1200px;margin:30px auto;padding:0 28px;}}
        h2   {{color:#003366;border-bottom:2px solid #003366;padding-bottom:8px;}}
        h3   {{color:#003366;}}
        .card{{background:white;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,.1);
               padding:24px;margin-bottom:20px;}}
        table{{border-collapse:collapse;width:100%;}}
        th   {{background:#003366;color:white;padding:10px 14px;text-align:left;}}
        td   {{padding:10px 14px;border-bottom:1px solid #eee;}}
        tr:hover td{{background:#f0f4ff;cursor:pointer;}}
        input,select,textarea
             {{width:100%;padding:8px 12px;border:1px solid #ccc;border-radius:4px;
               box-sizing:border-box;margin-top:4px;}}
        label{{display:block;font-weight:bold;font-size:13px;color:#333;margin-top:14px;}}
        .btn {{display:inline-block;padding:10px 20px;background:#003366;color:white;
               border:none;border-radius:4px;cursor:pointer;font-size:14px;
               margin-top:12px;text-decoration:none;}}
        .btn-success{{background:#1a7a1a;}}
        .btn-danger {{background:#cc3300;}}
        .btn-warn   {{background:#cc7700;}}
        .badge      {{display:inline-block;padding:4px 10px;border-radius:12px;
                      font-size:12px;font-weight:bold;}}
        .pending    {{background:#fff3cd;color:#856404;}}
        .approved   {{background:#d4edda;color:#155724;}}
        .rejected   {{background:#f8d7da;color:#721c24;}}
        .ok         {{background:#d1ecf1;color:#0c5460;}}
        .alert-ok   {{background:#d4edda;border:1px solid #c3e6cb;color:#155724;
                      padding:12px;border-radius:4px;margin-top:12px;}}
        .alert-err  {{background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;
                      padding:12px;border-radius:4px;margin-top:12px;}}
        .hidden     {{display:none !important;}}
        .metric-box {{display:inline-block;background:#003366;color:white;padding:20px 30px;
                      border-radius:8px;margin:8px;text-align:center;min-width:130px;}}
        .metric-val {{font-size:36px;font-weight:bold;display:block;}}
        .metric-lbl {{font-size:12px;opacity:.85;}}
    </style>
</head>
<body>
{nav}
<div class="wrap">
{body}
</div>
</body>
</html>'''


# ===========================================================================
# AUTH
# ===========================================================================

@app.route('/', methods=['GET'])
def index():
    return redirect('/login')


@app.route('/login', methods=['GET', 'POST'])
def login():
    error = ''
    if request.method == 'POST':
        username = request.form.get('username', '')
        password = request.form.get('password', '')
        user = USERS.get(username)
        if user and user['password'] == password:
            session['user'] = username
            session['role'] = user['role']
            return redirect('/dashboard')
        error = '<div class="alert-err">Invalid credentials. Please try again.</div>'

    body = f'''<div class="card" style="max-width:460px;margin:60px auto;">
        <h2 style="text-align:center;border:none;">🎓 NUST Postgraduate System</h2>
        <p style="text-align:center;color:#666;">RPA Service Account Login</p>
        <div id="login-form">
            <form method="POST" action="/login">
                {error}
                <label>Username / Email</label>
                <input id="username" name="username" type="text"
                       placeholder="e.g. hod@nust.na">
                <label>Password</label>
                <input id="password" name="password" type="password"
                       placeholder="Enter password">
                <button id="login-button" type="submit" class="btn"
                        style="width:100%;margin-top:20px;">
                    Login
                </button>
            </form>
        </div>
    </div>'''
    return page('Login', body, show_nav=False)


@app.route('/logout')
def logout():
    session.clear()
    return redirect('/login')


@app.route('/dashboard')
def dashboard():
    role = session.get('role', 'Unknown')
    user = session.get('user', '')
    body = f'''<h2>Dashboard</h2>
    <div class="card">
        <p>Welcome, <strong>{user}</strong></p>
        <p>Logged in as: <strong id="user-role-badge">{role}</strong></p>
        <hr>
        <h3>Quick Access</h3>
        <ul style="line-height:2;">
            <li><a href="/hod/approvals/pending">HoD Pending Approvals</a></li>
            <li><a href="/hod/evaluators/assign-internal">Assign Internal Evaluators</a></li>
            <li><a href="/hod/evaluators/propose-external">Propose External Evaluators</a></li>
            <li><a href="/admin/reports/weekly">Weekly Faculty Report</a></li>
            <li><a href="/admin/reports/completion-stats">Completion Statistics</a></li>
            <li><a href="/admin/reports/supervisor-workload">Supervisor Workload</a></li>
            <li><a href="/admin/reports/overdue">Overdue Submissions</a></li>
            <li><a href="/admin/notifications">Notification Centre</a></li>
            <li><a href="/student">Student Portal</a></li>
        </ul>
    </div>'''
    return page('Dashboard', body, role=role)


# ===========================================================================
# HOD MODULE
# ===========================================================================

@app.route('/hod')
@app.route('/hod/')
def hod_portal():
    return redirect('/hod/approvals/pending')


@app.route('/hod/approvals/pending')
def hod_pending():
    role = session.get('role', 'Head of Department')
    body = '''<h2>⚖️ HoD Pending Approvals Queue</h2>
    <div class="card">
        <table>
            <tr>
                <th>Submission ID</th><th>Student</th><th>Type</th>
                <th>Days Pending</th><th>Status</th><th>Action</th>
            </tr>
            <tr class="pending-approval"
                data-submission-id="SUB2026001"
                data-item-id="APP001"
                data-days-pending="5"
                onclick="window.location='/hod/submissions/SUB2026001'">
                <td>SUB2026001</td>
                <td>Tendai Moyo</td>
                <td>Summary of Proposals</td>
                <td>5</td>
                <td><span class="badge pending">Pending</span></td>
                <td>
                    <a href="/hod/submissions/SUB2026001" class="btn"
                       style="padding:5px 12px;font-size:12px;">Review</a>
                </td>
            </tr>
            <tr class="pending-approval"
                data-submission-id="THS2026001"
                data-item-id="APP002"
                data-days-pending="3"
                onclick="window.location='/hod/submissions/THS2026001'">
                <td>THS2026001</td>
                <td>Rudo Chigwedere</td>
                <td>Thesis</td>
                <td>3</td>
                <td><span class="badge pending">Pending</span></td>
                <td>
                    <a href="/hod/submissions/THS2026001" class="btn"
                       style="padding:5px 12px;font-size:12px;">Review</a>
                </td>
            </tr>
            <tr class="pending-approval"
                data-submission-id="SUB2026002"
                data-item-id="APP003"
                data-days-pending="10"
                onclick="window.location='/hod/submissions/SUB2026002'">
                <td>SUB2026002</td>
                <td>Amara Nkosi</td>
                <td>Progress Report</td>
                <td>10</td>
                <td><span class="badge rejected">Overdue</span></td>
                <td>
                    <a href="/hod/submissions/SUB2026002" class="btn btn-warn"
                       style="padding:5px 12px;font-size:12px;">Escalate</a>
                </td>
            </tr>
        </table>
    </div>
    <div class="card">
        <h3>Queue Summary</h3>
        <div id="pending-approvals-list">3 submissions awaiting HoD decision — 1 overdue</div>
        <div id="escalation-status" style="color:#cc3300;font-weight:bold;margin-top:8px;">
            Escalated
        </div>
    </div>'''
    return page('Pending Approvals', body, role=role)


@app.route('/hod/submissions/<sub_id>')
def hod_submission(sub_id):
    role = session.get('role', 'Head of Department')
    body = f'''<h2>📋 Submission Review: {sub_id}</h2>

    <div class="card" id="submission-details">
        <h3>Submission Details</h3>
        <table style="width:auto;">
            <tr><td><strong>ID</strong></td><td>{sub_id}</td></tr>
            <tr><td><strong>Student</strong></td><td>Tendai Moyo (PG2026001)</td></tr>
            <tr><td><strong>Program</strong></td><td>PhD Computer Science</td></tr>
            <tr><td><strong>Document</strong></td><td>Summary of Proposals</td></tr>
            <tr><td><strong>Submitted</strong></td><td>2026-05-25</td></tr>
        </table>
        <div id="student-record" style="margin-top:10px;">
            <p><strong>Student Email:</strong>
               <span id="student-email">tendai.moyo@students.nust.na</span></p>
        </div>
    </div>

    <div class="card" id="supervisor-comments">
        <h3>Supervisor Endorsement</h3>
        <p><em>"The student demonstrates a strong understanding of the research domain.
        The proposal is well-structured and meets all departmental guidelines.
        I recommend approval."</em></p>
        <p><strong>Supervisor:</strong>
           <span id="supervisor-email">j.chikwanha@nust.na</span></p>
    </div>

    <div class="card">
        <h3>Quality Evaluation Scores</h3>
        <table>
            <tr><th>Criterion</th><th>Score</th><th>Rating</th></tr>
            <tr>
                <td>Format Compliance</td>
                <td><span id="score-format_compliance" data-score="85">85/100</span></td>
                <td><span class="badge approved">Pass</span></td>
            </tr>
            <tr>
                <td>Content Completeness</td>
                <td><span id="score-content_completeness" data-score="80">80/100</span></td>
                <td><span class="badge approved">Pass</span></td>
            </tr>
            <tr>
                <td>Academic Rigor</td>
                <td><span id="score-academic_rigor" data-score="78">78/100</span></td>
                <td><span class="badge approved">Pass</span></td>
            </tr>
            <tr>
                <td>Originality</td>
                <td><span id="score-originality" data-score="88">88/100</span></td>
                <td><span class="badge approved">Pass</span></td>
            </tr>
            <tr>
                <td>Supervisor Endorsement</td>
                <td><span id="score-supervisor_endorsement" data-score="90">90/100</span></td>
                <td><span class="badge approved">Pass</span></td>
            </tr>
        </table>
        <div id="evaluation-feedback" style="margin-top:10px;color:#555;">
            Submission meets all academic standards. Recommend approval.
        </div>
    </div>

    <div class="card">
        <h3>HoD Decision</h3>
        <form method="POST" action="/hod/submissions/{sub_id}/decide"
              enctype="multipart/form-data">
            <label>Decision</label>
            <select id="approval-decision" name="decision">
                <option value="">— Select Decision —</option>
                <option value="Approve">Approve</option>
                <option value="Request Revision">Request Revision</option>
                <option value="Reject">Reject</option>
            </select>

            <label>Approval Comments</label>
            <input id="approval-comments" name="approval_comments" type="text"
                   placeholder="Enter approval comments...">

            <label>Digital Signature</label>
            <input id="digital-signature" name="signature" type="file"
                   accept=".png,.jpg,.pdf">

            <label>Revision Feedback</label>
            <input id="revision-feedback" name="revision_feedback" type="text"
                   placeholder="Describe required revisions...">

            <label>Revision Deadline</label>
            <input id="revision-deadline" name="revision_deadline" type="text"
                   placeholder="YYYY-MM-DD">

            <label>Rejection Reason</label>
            <input id="rejection-reason" name="rejection_reason" type="text"
                   placeholder="State reason for rejection...">

            <div id="fpgc-r-email" style="display:none;">fpgcr@nust.na</div>

            <button id="submit-approval" type="submit" name="action"
                    value="approve" class="btn btn-success">
                Submit Approval
            </button>
            <button id="submit-revision-request" type="submit" name="action"
                    value="revise" class="btn btn-warn" style="margin-left:10px;">
                Request Revision
            </button>
            <button id="submit-rejection" type="submit" name="action"
                    value="reject" class="btn btn-danger" style="margin-left:10px;">
                Reject
            </button>
        </form>
    </div>'''
    return page(f'Review {sub_id}', body, role=role)


@app.route('/hod/submissions/<sub_id>/decide', methods=['POST'])
def hod_decide(sub_id):
    action = request.form.get('action', 'approve')
    session[f'decision_{sub_id}'] = action
    return redirect(f'/hod/submissions/{sub_id}/confirmed?action={action}')


@app.route('/hod/submissions/<sub_id>/confirmed')
def hod_confirmed(sub_id):
    role = session.get('role', 'Head of Department')
    action = request.args.get('action', 'approve')

    if action == 'approve':
        status, msg, cls = 'Approved', 'Approved successfully', 'approved'
    elif action == 'revise':
        status, msg, cls = 'Pending', 'Revision requested successfully', 'pending'
    else:
        status, msg, cls = 'Rejected', 'Rejected successfully', 'rejected'

    body = f'''<h2>✅ Decision Recorded — {sub_id}</h2>
    <div class="card">
        <div id="approval-confirmation" class="alert-ok">{msg}</div>
        <div id="revision-confirmation" class="alert-ok" style="margin-top:6px;">
            Revision request recorded
        </div>
        <div id="rejection-confirmation" class="alert-err" style="margin-top:6px;">
            Rejection recorded
        </div>
        <hr>
        <p><strong>Submission:</strong> {sub_id}</p>
        <p><strong>Status:</strong>
            <span class="workflow-status-badge badge {cls}">{status}</span>
        </p>
        <p><strong>Routed to:</strong> FPGC Representative</p>
        <p><strong>Notified:</strong> fpgcr@nust.na, j.chikwanha@nust.na</p>
        <div id="fpgc-r-email"    style="display:none;">fpgcr@nust.na</div>
        <div id="supervisor-email" style="display:none;">j.chikwanha@nust.na</div>
        <div id="student-email"   style="display:none;">tendai.moyo@students.nust.na</div>
    </div>
    <a href="/hod/approvals/pending" class="btn" style="margin-top:8px;">
        ← Back to Queue
    </a>'''
    return page('Decision Confirmed', body, role=role)


# ---------------------------------------------------------------------------
# Evaluator Assignment
# ---------------------------------------------------------------------------

@app.route('/hod/evaluators/assign-internal', methods=['GET', 'POST'])
def hod_assign_internal():
    role = session.get('role', 'Head of Department')
    if request.method == 'POST':
        return redirect('/hod/evaluators/assigned')

    body = '''<h2>👥 Assign Internal Evaluators</h2>
    <div class="card">
        <form method="GET">
            <label>Student ID</label>
            <input id="student-id" name="student_id" type="text"
                   placeholder="e.g. PG2026001">
            <label>Proposal ID</label>
            <input id="proposal-id" name="proposal_id" type="text"
                   placeholder="e.g. PROP2026001">
            <label>Required Expertise</label>
            <input id="expertise-search" name="expertise" type="text"
                   placeholder="e.g. Machine Learning, Neural Networks">
            <button id="search-evaluators" type="button" class="btn"
                    onclick="showResults()">
                Search Evaluator Database
            </button>
        </form>
    </div>

    <div id="evaluator-results" class="card hidden">
        <h3>Matching Evaluators</h3>
        <form method="POST">
            <table>
                <tr>
                    <th>Select</th><th>Evaluator</th>
                    <th>Expertise Match</th><th>Current Workload</th>
                </tr>
                <tr class="evaluator-candidate"
                    data-evaluator-id="EVA001"
                    data-current-workload="2"
                    data-expertise-match="92">
                    <td><input type="checkbox" name="ev" value="EVA001" checked></td>
                    <td>Dr. A. Mutombo</td>
                    <td><span class="badge approved">92% match</span></td>
                    <td>2 active students</td>
                </tr>
                <tr class="evaluator-candidate"
                    data-evaluator-id="EVA002"
                    data-current-workload="3"
                    data-expertise-match="85">
                    <td><input type="checkbox" name="ev" value="EVA002" checked></td>
                    <td>Prof. N. Hamukwaya</td>
                    <td><span class="badge approved">85% match</span></td>
                    <td>3 active students</td>
                </tr>
                <tr class="evaluator-candidate"
                    data-evaluator-id="EVA003"
                    data-current-workload="7"
                    data-expertise-match="60">
                    <td><input type="checkbox" name="ev" value="EVA003"></td>
                    <td>Dr. T. Shikongo</td>
                    <td><span class="badge pending">60% match</span></td>
                    <td>7 active students (overloaded)</td>
                </tr>
            </table>
            <button id="confirm-assignment" type="submit"
                    class="btn btn-success" style="margin-top:16px;">
                Confirm Assignment
            </button>
        </form>
    </div>

    <script>
    function showResults() {
        var el = document.getElementById('evaluator-results');
        el.style.display = 'block';
        el.classList.remove('hidden');
    }
    </script>'''
    return page('Assign Internal Evaluators', body, role=role)


@app.route('/hod/evaluators/assigned')
def hod_assigned():
    role = session.get('role', 'Head of Department')
    body = '''<h2>✅ Evaluators Assigned</h2>
    <div class="card">
        <div id="assignment-confirmation" class="alert-ok">
            2 evaluators assigned successfully. Notifications dispatched.
        </div>
        <p><strong>Assigned:</strong> EVA001 (Dr. Mutombo), EVA002 (Prof. Hamukwaya)</p>
        <p><strong>Notifications sent to:</strong>
           e.mutombo@nust.na, n.hamukwaya@nust.na</p>
    </div>
    <a href="/hod/approvals/pending" class="btn">← Back to Approvals</a>'''
    return page('Evaluators Assigned', body, role=role)


@app.route('/hod/evaluators/propose-external', methods=['GET', 'POST'])
def hod_propose_external():
    role = session.get('role', 'Head of Department')
    if request.method == 'POST':
        return redirect('/hod/evaluators/proposal-submitted')

    body = '''<h2>🌍 Propose External Evaluators</h2>
    <div class="card">
        <form method="GET">
            <label>Student ID</label>
            <input id="student-id" name="student_id" type="text">
            <label>Thesis ID</label>
            <input id="thesis-id" name="thesis_id" type="text">
            <label>Expertise Area</label>
            <input id="expertise-area" name="expertise" type="text"
                   placeholder="e.g. Artificial Intelligence">
            <button id="search-external" type="button" class="btn"
                    onclick="showExternal()">
                Search External Evaluator Database
            </button>
        </form>
    </div>

    <div id="external-evaluator-results" class="card hidden">
        <h3>External Evaluator Candidates</h3>
        <form method="POST">
            <table>
                <tr>
                    <th>Select</th><th>Name</th>
                    <th>Institution</th><th>Profile Status</th>
                </tr>
                <tr class="external-candidate"
                    data-evaluator-id="EXT001" data-profile-complete="true">
                    <td><input type="checkbox" checked></td>
                    <td>Prof. D. Okonkwo</td>
                    <td>University of Cape Town</td>
                    <td><span class="badge approved">Complete</span></td>
                </tr>
                <tr class="external-candidate"
                    data-evaluator-id="EXT002" data-profile-complete="true">
                    <td><input type="checkbox" checked></td>
                    <td>Dr. S. Kariuki</td>
                    <td>Makerere University</td>
                    <td><span class="badge approved">Complete</span></td>
                </tr>
                <tr class="external-candidate"
                    data-evaluator-id="EXT003" data-profile-complete="true">
                    <td><input type="checkbox"></td>
                    <td>Prof. A. Diallo</td>
                    <td>University of Ghana</td>
                    <td><span class="badge approved">Complete</span></td>
                </tr>
            </table>
            <button id="submit-proposal" type="submit"
                    class="btn btn-success" style="margin-top:16px;">
                Submit Proposal to FPGC
            </button>
        </form>
    </div>

    <script>
    function showExternal() {
        var el = document.getElementById('external-evaluator-results');
        el.style.display = 'block';
        el.classList.remove('hidden');
    }
    </script>'''
    return page('Propose External Evaluators', body, role=role)


@app.route('/hod/evaluators/proposal-submitted')
def hod_proposal_submitted():
    role = session.get('role', 'Head of Department')
    body = '''<h2>✅ Proposal Submitted to FPGC</h2>
    <div class="card">
        <div id="proposal-confirmation" class="alert-ok">
            External evaluator proposal submitted successfully.
        </div>
        <p><strong>Reference:</strong>
           <span id="proposal-reference">PROP2026001</span></p>
        <p><strong>Forwarded to:</strong>
           <span id="fpgc-r-email">fpgcr@nust.na</span></p>
        <p>3 external evaluators proposed for review.</p>
    </div>
    <a href="/hod/approvals/pending" class="btn">← Back</a>'''
    return page('Proposal Submitted', body, role=role)


@app.route('/evaluator/<eval_id>/profile')
def evaluator_profile(eval_id):
    role = session.get('role', 'Unknown')
    emails = {
        'EVA001': 'e.mutombo@nust.na',
        'EVA002': 'n.hamukwaya@nust.na',
        'EVA003': 't.shikongo@nust.na',
        'EXT001': 'd.okonkwo@uct.ac.za',
        'EXT002': 's.kariuki@mak.ac.ug',
        'EXT003': 'a.diallo@ug.edu.gh',
    }
    email = emails.get(eval_id, f'{eval_id.lower()}@nust.na')
    body = f'''<h2>Evaluator Profile: {eval_id}</h2>
    <div class="card">
        <p><strong>Email:</strong> <span id="evaluator-email">{email}</span></p>
        <p><strong>Institution:</strong> NUST</p>
        <p><strong>Specialization:</strong> Computer Science</p>
        <p><strong>Profile Completeness:</strong>
           <span id="profile-completeness">100%</span></p>
    </div>'''
    return page('Evaluator Profile', body, role=role)


@app.route('/evaluator/<eval_id>/contact')
def evaluator_contact(eval_id):
    emails = {
        'Dr. Smith': 'smith@panel.edu',
        'Dr. Jones': 'jones@panel.edu',
        'Dr. Brown': 'brown@panel.edu',
    }
    email = emails.get(eval_id, f'panel.{eval_id.lower().replace(" ", "_")}@nust.na')
    body = f'<div class="card"><p id="member-email">{email}</p></div>'
    return page('Contact', body)


@app.route('/hod/workflow/<sub_id>/status')
def workflow_status(sub_id):
    role = session.get('role', 'Head of Department')
    body = f'''<h2>Workflow Status Tracker — {sub_id}</h2>
    <div class="card">
        <p><strong>Current Stage:</strong>
           <span id="current-stage">HoD Evaluation</span></p>
        <p><strong>Next Stage:</strong>
           <span id="next-stage">FPGC Review</span></p>
        <h3>History</h3>
        <div id="workflow-history">
            <div class="history-item"
                 style="padding:8px;border-left:3px solid #003366;margin-bottom:8px;">
                <strong>Student Submitted</strong> — 2026-05-20 09:15
            </div>
            <div class="history-item"
                 style="padding:8px;border-left:3px solid #1a7a1a;margin-bottom:8px;">
                <strong>Supervisor Reviewed &amp; Endorsed</strong> — 2026-05-22 14:30
            </div>
            <div class="history-item"
                 style="padding:8px;border-left:3px solid #cc7700;margin-bottom:8px;">
                <strong>HoD Evaluation</strong> — In Progress
            </div>
        </div>
    </div>'''
    return page('Workflow Status', body, role=role)


# ===========================================================================
# ADMIN REPORTS
# ===========================================================================

@app.route('/admin/reports/weekly', methods=['GET', 'POST'])
def reports_weekly():
    role = session.get('role', 'Unknown')
    body = '''<h2>📊 Weekly Faculty Report — Live Metrics</h2>
    <div class="card">
        <p style="color:#555;">
            Bot collects these live values and passes them to
            <code>Generate Faculty Report</code> to create an HTML report file.
        </p>
        <div style="margin:16px 0;">
            <div class="metric-box">
                <span class="metric-val" id="metric-total-students">47</span>
                <span class="metric-lbl">Total PG Students</span>
            </div>
            <div class="metric-box">
                <span class="metric-val" id="metric-active-submissions">23</span>
                <span class="metric-lbl">Active Submissions</span>
            </div>
            <div class="metric-box" style="background:#cc3300;">
                <span class="metric-val" id="metric-overdue-submissions">3</span>
                <span class="metric-lbl">Overdue</span>
            </div>
            <div class="metric-box">
                <span class="metric-val" id="metric-pending-reviews">8</span>
                <span class="metric-lbl">Pending Reviews</span>
            </div>
            <div class="metric-box" style="background:#1a7a1a;">
                <span class="metric-val" id="metric-completed-this-week">5</span>
                <span class="metric-lbl">Completed This Week</span>
            </div>
            <div class="metric-box" style="background:#0066aa;">
                <span class="metric-val" id="metric-supervisor-workload-avg">4.7</span>
                <span class="metric-lbl">Avg Supervisor Load</span>
            </div>
        </div>
    </div>'''
    return page('Weekly Report Metrics', body, role=role)


@app.route('/admin/reports/completion-stats', methods=['GET', 'POST'])
def reports_completion():
    role = session.get('role', 'Unknown')
    show = request.method == 'POST'
    vis = 'block' if show else 'none'

    body = f'''<h2>📈 Completion Statistics</h2>
    <div class="card">
        <form method="POST">
            <label>Report Period</label>
            <select id="report-period" name="period">
                <option value="monthly">Monthly</option>
                <option value="quarterly">Quarterly</option>
                <option value="annual">Annual</option>
            </select>
            <label>Program Filter</label>
            <select id="program-filter" name="program">
                <option value="all">All Programs</option>
                <option value="msc">MSc</option>
                <option value="phd">PhD</option>
                <option value="meng">MEng</option>
            </select>
            <button id="generate-report" type="submit" class="btn">
                Generate Statistics
            </button>
        </form>
    </div>
    <div id="completion-stats-results" class="card" style="display:{vis};">
        <h3>Completion Metrics</h3>
        <table>
            <tr><th>Metric</th><th>Value</th></tr>
            <tr><td>Total Enrolled</td>
                <td><span id="stat-total-enrolled">52</span></td></tr>
            <tr><td>Completed</td>
                <td><span id="stat-completed">18</span></td></tr>
            <tr><td>In Progress</td>
                <td><span id="stat-in-progress">29</span></td></tr>
            <tr><td>Withdrawn</td>
                <td><span id="stat-withdrawn">5</span></td></tr>
            <tr><td>Average Completion Time</td>
                <td><span id="stat-avg-completion-time">2.3 years</span></td></tr>
            <tr><td>Completion Rate</td>
                <td><span id="stat-completion-rate">78%</span></td></tr>
        </table>
    </div>'''
    return page('Completion Statistics', body, role=role)


@app.route('/admin/reports/supervisor-workload', methods=['GET', 'POST'])
def reports_workload():
    role = session.get('role', 'Unknown')
    show = request.method == 'POST'
    vis = 'block' if show else 'none'

    body = f'''<h2>👨‍🏫 Supervisor Workload Report</h2>
    <div class="card">
        <form method="POST">
            <label>Department</label>
            <select id="department-filter" name="department">
                <option value="all">All Departments</option>
                <option value="cs">Computer Science</option>
                <option value="eng">Engineering</option>
            </select>
            <button id="generate-workload-report" type="submit" class="btn">
                Generate Workload Report
            </button>
        </form>
    </div>
    <div id="workload-report-results" class="card" style="display:{vis};">
        <h3>Workload Distribution</h3>
        <table>
            <tr>
                <th>Supervisor</th><th>Students</th>
                <th>Active Reviews</th><th>Overdue</th><th>Recommendation</th>
            </tr>
            <tr class="supervisor-workload-row"
                data-supervisor-id="SUP001"
                data-name="Dr. J. Chikwanha"
                data-students="6"
                data-active-reviews="3"
                data-overdue-reviews="1">
                <td>Dr. J. Chikwanha</td>
                <td>6</td><td>3</td><td>1</td>
                <td><span class="badge ok">MONITOR</span></td>
            </tr>
            <tr class="supervisor-workload-row"
                data-supervisor-id="SUP002"
                data-name="Prof. A. Kaseke"
                data-students="9"
                data-active-reviews="5"
                data-overdue-reviews="3">
                <td>Prof. A. Kaseke</td>
                <td>9</td><td>5</td><td>3</td>
                <td><span class="badge rejected overloaded highlight warning">
                    REDISTRIBUTE
                </span></td>
            </tr>
            <tr class="supervisor-workload-row"
                data-supervisor-id="SUP003"
                data-name="Dr. E. Kamati"
                data-students="3"
                data-active-reviews="1"
                data-overdue-reviews="0">
                <td>Dr. E. Kamati</td>
                <td>3</td><td>1</td><td>0</td>
                <td><span class="badge approved">ACCEPT_NEW</span></td>
            </tr>
        </table>
    </div>'''
    return page('Supervisor Workload', body, role=role)


@app.route('/admin/reports/overdue', methods=['GET', 'POST'])
def reports_overdue():
    role = session.get('role', 'Unknown')
    show = request.method == 'POST'
    vis = 'block' if show else 'none'

    body = f'''<h2>⚠️ Overdue Submissions Report</h2>
    <div class="card">
        <form method="POST">
            <label>Escalation Level</label>
            <select id="escalation-filter" name="escalation_level">
                <option value="all">All Levels</option>
                <option value="high">High Priority Only</option>
                <option value="medium">Medium Priority</option>
                <option value="low">Low Priority</option>
            </select>
            <button id="generate-overdue-report" type="submit" class="btn">
                Generate Overdue Report
            </button>
        </form>
    </div>
    <div id="overdue-report-results" class="card" style="display:{vis};">
        <h3>Overdue Items — Days Overdue — Escalation Level</h3>
        <table>
            <tr>
                <th>Student</th><th>Type</th><th>Due Date</th>
                <th>Days Overdue</th><th>Supervisor</th>
                <th>Last Action</th><th>Escalation Level</th>
            </tr>
            <tr class="overdue-item"
                data-student-id="PG2026003"
                data-student-name="Amara Nkosi"
                data-type="Progress Report"
                data-due-date="2026-05-10"
                data-supervisor="SUP002"
                data-last-action="reminder_sent">
                <td>Amara Nkosi</td><td>Progress Report</td>
                <td>2026-05-10</td><td>20</td>
                <td>Prof. Kaseke</td><td>Reminder Sent</td>
                <td><span class="badge rejected">HIGH</span></td>
            </tr>
            <tr class="overdue-item"
                data-student-id="PG2026007"
                data-student-name="Sipho Dube"
                data-type="Thesis"
                data-due-date="2026-05-01"
                data-supervisor="SUP001"
                data-last-action="none">
                <td>Sipho Dube</td><td>Thesis</td>
                <td>2026-05-01</td><td>29</td>
                <td>Dr. Chikwanha</td><td>None</td>
                <td><span class="badge rejected">HIGH</span></td>
            </tr>
            <tr class="overdue-item"
                data-student-id="PG2026012"
                data-student-name="Rudo Chigwedere"
                data-type="Table of Changes"
                data-due-date="2026-05-22"
                data-supervisor="SUP003"
                data-last-action="escalated">
                <td>Rudo Chigwedere</td><td>Table of Changes</td>
                <td>2026-05-22</td><td>8</td>
                <td>Dr. Kamati</td><td>Escalated</td>
                <td><span class="badge pending">MEDIUM</span></td>
            </tr>
        </table>
    </div>'''
    return page('Overdue Submissions', body, role=role)


# ===========================================================================
# NOTIFICATION CENTRE
# ===========================================================================

@app.route('/admin/notifications', methods=['GET', 'POST'])
def notifications():
    role = session.get('role', 'Unknown')
    if request.method == 'POST':
        return redirect('/admin/notifications?logged=1')

    msg = ''
    if request.args.get('logged'):
        msg = '<div class="alert-ok">✅ Notification logged in system.</div>'

    body = f'''<h2>🔔 Notification Centre</h2>
    <div class="card">
        {msg}
        <h3>Log Notification</h3>
        <form method="POST" action="/admin/notifications">
            <label>Notification ID</label>
            <input id="notification-id" name="notification_id"
                   type="text" placeholder="NOTIF_...">
            <label>Recipient</label>
            <input id="recipient" name="recipient"
                   type="text" placeholder="email@nust.na">
            <label>Notification Type</label>
            <select id="notification-type" name="notification_type">
                <option>Approval Notification</option>
                <option>Rejection Notification</option>
                <option>Reminder</option>
                <option>Escalation Alert</option>
                <option>Submission Confirmation</option>
            </select>
            <label>Priority</label>
            <select id="priority" name="priority">
                <option>normal</option>
                <option>high</option>
                <option>urgent</option>
                <option>low</option>
            </select>
            <label>Subject</label>
            <input id="subject" name="subject" type="text">
            <label>Content</label>
            <textarea id="content" name="content" rows="3"></textarea>
            <button id="log-notification" type="submit" class="btn">
                Log Notification
            </button>
        </form>
    </div>
    <div class="card">
        <h3>Recent Activity</h3>
        <div id="notification-log">
            Approval Notification → fpgcr@nust.na (SUB2026001 approved) |
            Reminder → j.chikwanha@nust.na (pending review)
        </div>
    </div>'''
    return page('Notification Centre', body, role=role)


# ===========================================================================
# COMMITTEE CONTACTS
# ===========================================================================

@app.route('/admin/committee/contacts')
def committee_contacts():
    role = session.get('role', 'Unknown')
    body = '''<h2>FPGC &amp; HDC Committee Contacts</h2>
    <div class="card">
        <table>
            <tr><th>Name</th><th>Role</th><th>Email</th></tr>
            <tr>
                <td>Prof. M. Hamunyela</td><td>FPGC Chair</td>
                <td><span class="committee-email">fpgc@nust.na</span></td>
            </tr>
            <tr>
                <td>Ms. N. Shilongo</td><td>FPGCR Secretary</td>
                <td><span class="committee-email">fpgcr@nust.na</span></td>
            </tr>
            <tr>
                <td>Dr. P. Nghaamwa</td><td>HDC Member</td>
                <td><span class="committee-email">hdc-chair@nust.na</span></td>
            </tr>
        </table>
    </div>'''
    return page('Committee Contacts', body, role=role)


# ===========================================================================
# ORAL DEFENSE
# ===========================================================================

@app.route('/admin/oral-defense/schedule', methods=['GET', 'POST'])
def oral_defense():
    role = session.get('role', 'Unknown')
    if request.method == 'POST':
        return redirect('/admin/oral-defense/scheduled')

    body = '''<h2>📅 Schedule Oral Defense</h2>
    <div class="card">
        <form method="POST">
            <label>Student ID</label>
            <input id="student-id" name="student_id" type="text">
            <label>Thesis ID</label>
            <input id="thesis-id" name="thesis_id" type="text">
            <label>Defense Date</label>
            <select id="defense-date" name="defense_date">
                <option value="2026-06-20">2026-06-20</option>
                <option value="2026-06-27">2026-06-27</option>
            </select>
            <label>Defense Time</label>
            <input id="defense-time" name="defense_time" type="text" value="09:00">
            <label>Venue</label>
            <input id="venue" name="venue" type="text" value="Room A101">
            <label>Add Panel Member</label>
            <select id="panel-member" name="panel_member">
                <option value="Dr. Smith">Dr. Smith</option>
                <option value="Dr. Jones">Dr. Jones</option>
                <option value="Dr. Brown">Dr. Brown</option>
            </select>
            <button id="add-panel-member" type="button" class="btn"
                    onclick="alert('Panel member added.')">
                Add Panel Member
            </button>
            <button id="confirm-schedule" type="submit"
                    class="btn btn-success" style="margin-top:16px;">
                Confirm Defense Schedule
            </button>
        </form>
    </div>'''
    return page('Schedule Oral Defense', body, role=role)


@app.route('/admin/oral-defense/scheduled')
def oral_defense_scheduled():
    role = session.get('role', 'Unknown')
    body = '''<h2>✅ Oral Defense Scheduled</h2>
    <div class="card">
        <div id="schedule-confirmation" class="alert-ok">
            Oral defense scheduled successfully.
        </div>
        <p><strong>Reference:</strong>
           <span id="defense-reference">DEF20260001</span></p>
        <p><strong>Student:</strong>
           <span id="student-email">tendai.moyo@students.nust.na</span></p>
        <p><strong>Supervisor:</strong>
           <span id="supervisor-email">j.chikwanha@nust.na</span></p>
        <p><strong>Date:</strong> 2026-06-20 at 09:00 — Room A101</p>
    </div>'''
    return page('Defense Scheduled', body, role=role)


# ===========================================================================
# STUDENT PORTAL
# ===========================================================================

@app.route('/student')
@app.route('/student/')
def student_portal():
    role = session.get('role', 'Student')
    body = '''<h2>🎓 Student Portal</h2>
    <div class="card">
        <p>Welcome to your Postgraduate Student Portal.</p>
        <p>Use the links below to manage your postgraduate journey.</p>
        <ul style="line-height:2.2;">
            <li><a href="/student/application/new">📝 New Postgraduate Application</a></li>
            <li><a href="/student/progress-report/new">📊 Submit Semester Progress Report</a></li>
            <li><a href="/student/applications">📁 My Applications</a></li>
        </ul>
    </div>'''
    return page('Student Portal', body, role=role)


@app.route('/student/application/new', methods=['GET', 'POST'])
def student_application_new():
    role = session.get('role', 'Student')
    if request.method == 'POST':
        return redirect('/student/application/submitted')

    body = '''<h2>📝 New Postgraduate Application</h2>
    <div class="card">
        <form method="POST" enctype="multipart/form-data">
            <label>First Name</label>
            <input id="first-name" name="first_name" type="text"
                   placeholder="e.g. Tendai">
            <label>Last Name</label>
            <input id="last-name" name="last_name" type="text"
                   placeholder="e.g. Moyo">
            <label>Email Address</label>
            <input id="email" name="email" type="email"
                   placeholder="student@nust.na">
            <label>Programme</label>
            <select id="program" name="program">
                <option value="">— Select Programme —</option>
                <option value="MSc CS">MSc Computer Science</option>
                <option value="PhD IS">PhD Information Systems</option>
                <option value="MEng SE">MEng Software Engineering</option>
                <option value="PhD DS">PhD Data Science</option>
            </select>
            <label>Research Area</label>
            <input id="research-area" name="research_area" type="text"
                   placeholder="e.g. Machine Learning, NLP">
            <label>Proposed Supervisor</label>
            <select id="proposed-supervisor" name="supervisor">
                <option value="">— Select Supervisor —</option>
                <option value="SUP001">Dr. J. Chikwanha</option>
                <option value="SUP002">Prof. A. Kaseke</option>
                <option value="SUP003">Dr. E. Kamati</option>
            </select>
            <label>Personal Statement</label>
            <textarea id="personal-statement" name="personal_statement"
                      rows="4"
                      placeholder="Describe your research motivation...">
            </textarea>
            <label>Qualification Document (PDF)</label>
            <input id="qualification-document" name="qualification"
                   type="file" accept=".pdf">
            <button id="submit-application" type="submit"
                    class="btn btn-success" style="margin-top:16px;">
                Submit Application
            </button>
        </form>
    </div>'''
    return page('New Application', body, role=role)


@app.route('/student/application/submitted')
def student_application_submitted():
    role = session.get('role', 'Student')
    body = '''<h2>✅ Application Submitted</h2>
    <div class="card">
        <div id="application-confirmation" class="alert-ok">
            Application submitted successfully.
        </div>
        <p><strong>Reference Number:</strong>
           <span id="application-reference">APP2026001</span></p>
        <p><strong>Status:</strong>
            <span class="workflow-status-badge badge pending">Pending Review</span>
        </p>
        <p>You will receive an email notification once your application is reviewed.</p>
    </div>
    <a href="/student" class="btn">← Back to Portal</a>'''
    return page('Application Submitted', body, role=role)


@app.route('/student/progress-report/new', methods=['GET', 'POST'])
def student_progress_report():
    role = session.get('role', 'Student')
    if request.method == 'POST':
        return redirect('/student/progress-report/submitted')

    body = '''<h2>📊 Semester Progress Report</h2>
    <div class="card">
        <form method="POST">
            <label>Reporting Semester</label>
            <select id="semester" name="semester">
                <option value="2026-S1">Semester 1, 2026</option>
                <option value="2026-S2">Semester 2, 2026</option>
            </select>
            <label>Research Progress Summary</label>
            <textarea id="research-progress" name="progress" rows="4"
                      placeholder="Summarise research progress this semester...">
            </textarea>
            <label>Objectives Achieved</label>
            <textarea id="objectives-achieved" name="objectives" rows="3"
                      placeholder="List objectives achieved...">
            </textarea>
            <label>Challenges Encountered</label>
            <textarea id="challenges" name="challenges" rows="3"
                      placeholder="Describe challenges faced...">
            </textarea>
            <label>Plan for Next Semester</label>
            <textarea id="next-semester-plan" name="plan" rows="3"
                      placeholder="Outline plan for next semester...">
            </textarea>
            <label>Supervisor Consultation Hours This Semester</label>
            <input id="consultation-hours" name="consultation_hours"
                   type="number" placeholder="e.g. 12">
            <button id="submit-progress-report" type="submit"
                    class="btn btn-success" style="margin-top:16px;">
                Submit Progress Report
            </button>
        </form>
    </div>'''
    return page('Progress Report', body, role=role)


@app.route('/student/progress-report/submitted')
def student_progress_submitted():
    role = session.get('role', 'Student')
    body = '''<h2>✅ Progress Report Submitted</h2>
    <div class="card">
        <div id="report-confirmation" class="alert-ok">
            Progress report submitted successfully.
        </div>
        <p><strong>Reference:</strong>
           <span id="report-reference">REP2026001</span></p>
        <p><strong>Status:</strong>
            <span class="workflow-status-badge badge pending">
                Pending Supervisor Review
            </span>
        </p>
    </div>
    <a href="/student" class="btn">← Back to Portal</a>'''
    return page('Report Submitted', body, role=role)


# ===========================================================================
# ENTRY POINT
# ===========================================================================

if __name__ == '__main__':
    print()
    print("=" * 62)
    print("  NUST PGS Demo Mock Server")
    print("  URL  : http://127.0.0.1:5000")
    print("  Login: hod@nust.na  /  password")
    print("  Login: tendai.moyo@students.nust.na  /  password")
    print("=" * 62)
    print()
    app.run(debug=False, host='127.0.0.1', port=5000)
