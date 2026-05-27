@echo off
:: ============================================================
:: NUST PGS — RPA Suite Runner
:: Usage:
::   run_tests.bat              – validate bot credentials (live routes only)
::   run_tests.bat routing      – auto-routing and evaluator assignment processes
::   run_tests.bat pipeline-a   – full Proposal Registration Pipeline (A1–A8)
::   run_tests.bat pipeline-b   – full Thesis Examination Pipeline (B1–B7)
::   run_tests.bat pipelines    – both end-to-end pipelines
::   run_tests.bat reports      – report generation and claims processing
::   run_tests.bat full         – complete regression (all processes)
:: ============================================================

if "%1"=="" goto credential_check
if "%1"=="routing" goto routing
if "%1"=="pipeline-a" goto pipeline_a
if "%1"=="pipeline-b" goto pipeline_b
if "%1"=="pipelines" goto pipelines
if "%1"=="reports" goto reports
if "%1"=="full" goto full
echo Unknown option: %1
goto usage

:credential_check
echo [RPA] Validating bot credentials for all 7 roles...
robot --outputdir results --exclude pending --loglevel INFO ^
      --reporttitle "NUST PGS RPA — Credential Validation" ^
      tests/01_authentication/ tests/02_settings/
goto end

:routing
echo [RPA] Running auto-routing and evaluator assignment processes...
robot --outputdir results --include rpa-routing --include rpa-assignment ^
      --loglevel INFO ^
      --reporttitle "NUST PGS RPA — Auto-Routing and Assignment" ^
      tests/
goto end

:pipeline_a
echo [RPA] Running Pipeline A — Proposal Registration (A1-A8)...
robot --outputdir results --include pipeline-a --loglevel INFO ^
      --reporttitle "NUST PGS RPA — Pipeline A: Proposal Registration" ^
      tests/09_e2e/
goto end

:pipeline_b
echo [RPA] Running Pipeline B — Thesis Examination (B1-B7)...
robot --outputdir results --include pipeline-b --loglevel INFO ^
      --reporttitle "NUST PGS RPA — Pipeline B: Thesis Examination" ^
      tests/09_e2e/
goto end

:pipelines
echo [RPA] Running both end-to-end pipelines (A and B)...
robot --outputdir results --include rpa-pipeline --loglevel INFO ^
      --reporttitle "NUST PGS RPA — Full Pipeline Run" ^
      tests/09_e2e/
goto end

:reports
echo [RPA] Running report generation and claims processing...
robot --outputdir results --include rpa-report --loglevel INFO ^
      --reporttitle "NUST PGS RPA — Report Generation" ^
      tests/
goto end

:full
echo [RPA] Running full regression suite (all processes, all roles)...
robot --outputdir results --loglevel DEBUG ^
      --reporttitle "NUST PGS RPA — Full Regression" ^
      tests/
goto end

:usage
echo.
echo Usage: run_tests.bat [option]
echo   (no option)  – validate bot credentials
echo   routing      – auto-routing and evaluator assignment
echo   pipeline-a   – Proposal Registration Pipeline
echo   pipeline-b   – Thesis Examination Pipeline
echo   pipelines    – both end-to-end pipelines
echo   reports      – report generation and claims processing
echo   full         – complete regression suite

:end
echo.
echo Results saved to results/log.html
