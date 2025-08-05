@echo off
echo ========================================
echo    Expense Tracker - Demo Launcher
echo ========================================
echo.
echo Launching all demonstration pages...
echo.

REM Check if we're in the correct directory
if not exist "index.html" (
    echo Error: Please run this script from the demo directory
    echo Current directory: %CD%
    pause
    exit /b 1
)

echo Starting demo pages...
echo.

REM Launch main demo page
echo [1/9] Opening main demo page...
start "" "index.html"

REM Wait 5 seconds
echo Waiting 5 seconds before next page...
timeout /t 5 /nobreak >nul

REM Launch individual component demos
echo [2/9] Opening Dashboard demo...
start "" "dashboard.html"

echo Waiting 5 seconds before next page...
timeout /t 5 /nobreak >nul

echo [3/9] Opening Receipt Scanner demo...
start "" "receipt-scanner.html"

echo Waiting 5 seconds before next page...
timeout /t 5 /nobreak >nul

echo [4/9] Opening Expense Management demo...
start "" "expense-management.html"

echo Waiting 5 seconds before next page...
timeout /t 5 /nobreak >nul

echo [5/9] Opening Analytics demo...
start "" "analytics.html"

echo Waiting 5 seconds before next page...
timeout /t 5 /nobreak >nul

echo [6/9] Opening Budget Tracking demo...
start "" "budget-tracking.html"

echo Waiting 5 seconds before next page...
timeout /t 5 /nobreak >nul

echo [7/9] Opening Settings demo...
start "" "settings.html"

echo Waiting 5 seconds before next page...
timeout /t 5 /nobreak >nul

echo [8/9] Opening Authentication demos...
start "" "login.html"
start "" "register.html"

echo Waiting 5 seconds before next page...
timeout /t 5 /nobreak >nul

echo [9/9] Opening Mobile Experience demo...
start "" "mobile-demo.html"

echo.
echo ========================================
echo All demo pages have been launched!
echo ========================================
echo.
echo Demo pages opened:
echo - Main Demo (index.html)
echo - Dashboard (dashboard.html)
echo - Receipt Scanner (receipt-scanner.html)
echo - Expense Management (expense-management.html)
echo - Analytics (analytics.html)
echo - Budget Tracking (budget-tracking.html)
echo - Settings (settings.html)
echo - Login (login.html)
echo - Registration (register.html)
echo - Mobile Experience (mobile-demo.html)
echo.
echo Note: Each page will open in a new browser tab.
echo You can close individual tabs or use Ctrl+W to close them.
echo.
pause 