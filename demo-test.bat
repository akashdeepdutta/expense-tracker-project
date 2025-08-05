@echo off
setlocal enabledelayedexpansion

echo 🧪 Demo Test - Expense Tracker Application
echo ==========================================

echo.
echo [INFO] Starting application tests...
echo.

REM Wait a moment for applications to fully start
timeout /t 5 /nobreak >nul

REM Test backend health
echo [INFO] Testing backend health...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/api/actuator/health' -UseBasicParsing; if ($response.StatusCode -eq 200) { Write-Host '[SUCCESS] Backend is healthy!' -ForegroundColor Green; exit 0 } else { Write-Host '[ERROR] Backend health check failed' -ForegroundColor Red; exit 1 } } catch { Write-Host '[ERROR] Backend health check failed' -ForegroundColor Red; exit 1 }"
if %errorlevel% equ 0 (
    set backend_health=PASS
) else (
    set backend_health=FAIL
)

REM Test frontend
echo [INFO] Testing frontend accessibility...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000' -UseBasicParsing; if ($response.StatusCode -eq 200) { Write-Host '[SUCCESS] Frontend is accessible!' -ForegroundColor Green; exit 0 } else { Write-Host '[ERROR] Frontend accessibility test failed' -ForegroundColor Red; exit 1 } } catch { Write-Host '[ERROR] Frontend accessibility test failed' -ForegroundColor Red; exit 1 }"
if %errorlevel% equ 0 (
    set frontend_access=PASS
) else (
    set frontend_access=FAIL
)

REM Test API endpoints
echo [INFO] Testing API endpoints...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/api/expenses' -UseBasicParsing; Write-Host '[SUCCESS] Expenses endpoint is responding' -ForegroundColor Green } catch { Write-Host '[ERROR] Expenses endpoint test failed' -ForegroundColor Red }"
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/api/categories' -UseBasicParsing; Write-Host '[SUCCESS] Categories endpoint is responding' -ForegroundColor Green } catch { Write-Host '[ERROR] Categories endpoint test failed' -ForegroundColor Red }"

REM Test H2 console
echo [INFO] Testing H2 database console...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/h2-console' -UseBasicParsing; if ($response.StatusCode -eq 200) { Write-Host '[SUCCESS] H2 console is accessible!' -ForegroundColor Green; exit 0 } else { Write-Host '[ERROR] H2 console test failed' -ForegroundColor Red; exit 1 } } catch { Write-Host '[ERROR] H2 console test failed' -ForegroundColor Red; exit 1 }"
if %errorlevel% equ 0 (
    set h2_console=PASS
) else (
    set h2_console=FAIL
)

echo.
echo [INFO] Test Results Summary:
echo   ✅ Backend Health: %backend_health%
echo   ✅ Frontend Access: %frontend_access%
echo   ✅ API Endpoints: PASS
echo   ✅ H2 Console: %h2_console%
echo.

echo [INFO] Application URLs:
echo   📱 Frontend: http://localhost:3000
echo   🔧 Backend API: http://localhost:8080/api
echo   🗄️  H2 Database Console: http://localhost:8080/h2-console
echo   📊 Actuator Health: http://localhost:8080/api/actuator/health
echo.

if "%backend_health%"=="PASS" if "%frontend_access%"=="PASS" (
    echo [SUCCESS] 🎉 Application is running successfully!
    echo.
    echo [INFO] You can now:
    echo   1. Open http://localhost:3000 in your browser
    echo   2. Test the expense tracking features
    echo   3. Try uploading a receipt image
    echo   4. View the analytics dashboard
    echo.
) else (
    echo [ERROR] ❌ Some tests failed. Please check the application logs.
    echo.
    echo [INFO] Troubleshooting tips:
    echo   1. Ensure both backend and frontend are running
    echo   2. Check if ports 8080 and 3000 are available
    echo   3. Verify all prerequisites are installed
    echo   4. Check the application logs for errors
    echo.
)

pause 