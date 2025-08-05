#!/bin/bash

echo "========================================"
echo "   Expense Tracker - Demo Launcher"
echo "========================================"
echo
echo "Launching all demonstration pages..."
echo

# Check if we're in the correct directory
if [ ! -f "index.html" ]; then
    echo "Error: Please run this script from the demo directory"
    echo "Current directory: $(pwd)"
    exit 1
fi

echo "Starting demo pages..."
echo

# Function to open URL based on OS
open_url() {
    local url="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open "$url"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v xdg-open > /dev/null; then
            xdg-open "$url"
        elif command -v gnome-open > /dev/null; then
            gnome-open "$url"
        else
            echo "Could not open browser automatically. Please open $url manually."
        fi
    else
        echo "Unsupported OS. Please open $url manually."
    fi
}

# Launch main demo page
echo "[1/9] Opening main demo page..."
open_url "index.html"
echo "Waiting 5 seconds before next page..."
sleep 5

# Launch individual component demos
echo "[2/9] Opening Dashboard demo..."
open_url "dashboard.html"
echo "Waiting 5 seconds before next page..."
sleep 5

echo "[3/9] Opening Receipt Scanner demo..."
open_url "receipt-scanner.html"
echo "Waiting 5 seconds before next page..."
sleep 5

echo "[4/9] Opening Expense Management demo..."
open_url "expense-management.html"
echo "Waiting 5 seconds before next page..."
sleep 5

echo "[5/9] Opening Analytics demo..."
open_url "analytics.html"
echo "Waiting 5 seconds before next page..."
sleep 5

echo "[6/9] Opening Budget Tracking demo..."
open_url "budget-tracking.html"
echo "Waiting 5 seconds before next page..."
sleep 5

echo "[7/9] Opening Settings demo..."
open_url "settings.html"
echo "Waiting 5 seconds before next page..."
sleep 5

echo "[8/9] Opening Authentication demos..."
open_url "login.html"
open_url "register.html"
echo "Waiting 5 seconds before next page..."
sleep 5

echo "[9/9] Opening Mobile Experience demo..."
open_url "mobile-demo.html"

echo
echo "========================================"
echo "All demo pages have been launched!"
echo "========================================"
echo
echo "Demo pages opened:"
echo "- Main Demo (index.html)"
echo "- Dashboard (dashboard.html)"
echo "- Receipt Scanner (receipt-scanner.html)"
echo "- Expense Management (expense-management.html)"
echo "- Analytics (analytics.html)"
echo "- Budget Tracking (budget-tracking.html)"
echo "- Settings (settings.html)"
echo "- Login (login.html)"
echo "- Registration (register.html)"
echo "- Mobile Experience (mobile-demo.html)"
echo
echo "Note: Each page will open in a new browser tab."
echo "You can close individual tabs or use Cmd+W (Mac) / Ctrl+W (Linux) to close them."
echo 