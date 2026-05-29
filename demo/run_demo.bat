@echo off
setlocal

REM ============================================================
REM  NUST PGS RPA Demo Launcher
REM  Usage:  run_demo.bat [suite]
REM
REM  Suites:
REM    (no arg)    Run all 3 demo suites (recommended for demo day)
REM    hod         Suite 1 — HoD Approval Workflow
REM    reports     Suite 2 — Report Generation (most impressive)
REM    student     Suite 3 — Student Intake
REM    server      Start mock server only (no tests)
REM    install     Install Python dependencies only
REM ============================================================

set DEMO_DIR=%~dp0
set RESULTS_DIR=%DEMO_DIR%results
set REPORTS_DIR=%DEMO_DIR%reports
set SERVER_PORT=5000
set SERVER_URL=http://127.0.0.1:%SERVER_PORT%

echo.
echo  ===========================================================
echo   NUST PGS RPA Demo Suite
echo   ASD810S Assignment II
echo  ===========================================================
echo.

REM ── 1. Install dependencies if requested ────────────────────
if "%1"=="install" (
    echo [SETUP] Installing Python dependencies...
    pip install robotframework robotframework-seleniumlibrary flask webdriver-manager
    echo [SETUP] Done. Run: run_demo.bat
    goto :end
)

REM ── 2. Check Python is available ────────────────────────────
where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Install Python 3.9+ and add to PATH.
    pause
    goto :end
)

REM ── 3. Check Robot Framework is available ───────────────────
python -c "import robot" >nul 2>&1
if errorlevel 1 (
    echo [SETUP] Robot Framework not found. Installing dependencies...
    pip install robotframework robotframework-seleniumlibrary flask webdriver-manager
)

REM ── 4. Check Flask is available ─────────────────────────────
python -c "import flask" >nul 2>&1
if errorlevel 1 (
    echo [SETUP] Flask not found. Installing...
    pip install flask
)

REM ── 5. Create required directories ──────────────────────────
if not exist "%RESULTS_DIR%"              mkdir "%RESULTS_DIR%"
if not exist "%REPORTS_DIR%"              mkdir "%REPORTS_DIR%"
if not exist "%REPORTS_DIR%\archive"      mkdir "%REPORTS_DIR%\archive"
if not exist "%DEMO_DIR%data\test_data"   mkdir "%DEMO_DIR%data\test_data"

REM ── 6. Start mock server only if requested ──────────────────
if "%1"=="server" (
    echo [SERVER] Starting mock server at %SERVER_URL%
    echo [SERVER] Press Ctrl+C to stop
    echo.
    python "%DEMO_DIR%mock_server.py"
    goto :end
)

REM ── 7. Start mock server in background ──────────────────────
echo [SERVER] Starting NUST PGS mock server at %SERVER_URL% ...
start "NUST-PGS-MockServer" /min python "%DEMO_DIR%mock_server.py"

REM Give server 3 seconds to start
timeout /t 3 /nobreak >nul

REM Verify server started
python -c "import urllib.request; urllib.request.urlopen('%SERVER_URL%/login')" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Mock server did not start. Check Python/Flask installation.
    goto :cleanup
)
echo [SERVER] Mock server is running.
echo.

REM ── 8. Run tests based on argument ──────────────────────────
cd /d "%DEMO_DIR%"

if "%1"=="hod" (
    echo [TEST] Running Suite 1 — HoD Workflow Demo...
    python -m robot --outputdir "%RESULTS_DIR%" --include demo --include hod ^
        --log "%RESULTS_DIR%\hod_log.html" ^
        --report "%RESULTS_DIR%\hod_report.html" ^
        tests\01_hod_workflow_demo.robot
    goto :open_report
)

if "%1"=="reports" (
    echo [TEST] Running Suite 2 — Report Generation Demo...
    python -m robot --outputdir "%RESULTS_DIR%" --include demo --include reports ^
        --log "%RESULTS_DIR%\reports_log.html" ^
        --report "%RESULTS_DIR%\reports_report.html" ^
        tests\02_report_generation_demo.robot
    goto :open_report
)

if "%1"=="student" (
    echo [TEST] Running Suite 3 — Student Intake Demo...
    python -m robot --outputdir "%RESULTS_DIR%" --include demo --include student ^
        --log "%RESULTS_DIR%\student_log.html" ^
        --report "%RESULTS_DIR%\student_report.html" ^
        tests\03_student_intake_demo.robot
    goto :open_report
)

REM Default: run ALL suites
echo [TEST] Running all 3 demo suites...
echo.
python -m robot ^
    --outputdir "%RESULTS_DIR%" ^
    --log "%RESULTS_DIR%\log.html" ^
    --report "%RESULTS_DIR%\report.html" ^
    --name "NUST PGS RPA Demo" ^
    tests\

:open_report
echo.
echo  ===========================================================
echo   Demo run complete!
echo.
echo   Robot report  : %RESULTS_DIR%\report.html
echo   Robot log     : %RESULTS_DIR%\log.html
echo   HTML report   : %REPORTS_DIR%\weekly_faculty_report_*.html
echo   CSV report    : %REPORTS_DIR%\overdue_submissions_*.csv
echo  ===========================================================
echo.

REM Open Robot Framework report in browser
start "" "%RESULTS_DIR%\report.html" 2>nul

REM Open generated HTML report if it exists
for %%f in ("%REPORTS_DIR%\weekly_faculty_report_*.html") do (
    echo [OPEN] Opening generated faculty report...
    start "" "%%f"
)

:cleanup
echo [SERVER] Stopping mock server...
taskkill /FI "WINDOWTITLE eq NUST-PGS-MockServer" /F >nul 2>&1

:end
echo.
endlocal
