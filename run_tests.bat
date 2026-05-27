@echo off
REM ============================================================
REM NUST PGS – Robot Framework Test Runner
REM
REM Usage:
REM   run_tests.bat          -> smoke tests only  (fast, ~2 min)
REM   run_tests.bat full     -> all non-pending tests
REM   run_tests.bat auth     -> auth + settings only
REM ============================================================

SET RESULTS=results
SET APP_PATH=C:\Users\PayToday\Downloads\Speakers\NUST_App\NUST-Postgraduate-System-main

REM Start Laravel server in background if not already running
tasklist /FI "IMAGENAME eq php.exe" 2>NUL | find /I "php.exe" >NUL
IF ERRORLEVEL 1 (
    echo Starting Laravel server on http://localhost:8000 ...
    START /B C:\php8\php.exe "%APP_PATH%\artisan" serve --host=127.0.0.1 --port=8000 > nul 2>&1
    timeout /t 3 /nobreak > nul
)

IF "%1"=="full" (
    echo Running FULL regression suite (excluding pending)...
    robot --outputdir %RESULTS% --exclude pending --loglevel DEBUG tests/
) ELSE IF "%1"=="auth" (
    echo Running auth + settings only...
    robot --outputdir %RESULTS% tests/01_authentication/ tests/02_settings/
) ELSE (
    echo Running SMOKE tests...
    robot --outputdir %RESULTS% --include smoke --loglevel INFO tests/
)

echo.
echo Results saved to %RESULTS%\
echo Open %RESULTS%\log.html in a browser for the full report.
