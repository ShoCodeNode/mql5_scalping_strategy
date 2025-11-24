@echo off
echo =====================================
echo MQL5 Scalping Strategy Setup Check
echo =====================================
echo.

REM Check if MetaTrader 5 is installed
echo [1/5] Checking MetaTrader 5 installation...
if exist "C:\Program Files\MetaTrader 5\terminal64.exe" (
    echo ✓ MetaTrader 5 found
) else (
    echo ✗ MetaTrader 5 not found in standard location
    echo Please install MetaTrader 5 from https://www.metatrader5.com/
)
echo.

REM Check MQL5 directory
echo [2/5] Checking MQL5 directory structure...
set "MQL5_PATH=%APPDATA%\MetaQuotes\Terminal"
if exist "%MQL5_PATH%" (
    echo ✓ MQL5 data folder found: %MQL5_PATH%
) else (
    echo ✗ MQL5 data folder not found
    echo Please run MetaTrader 5 at least once to create the folder structure
)
echo.

REM Check project files
echo [3/5] Checking project files...
if exist "Experts\AdaptiveScalpingEA.mq5" (
    echo ✓ Main EA file found
) else (
    echo ✗ AdaptiveScalpingEA.mq5 not found
)

if exist "Include\ScalpingConfig.mqh" (
    echo ✓ Configuration file found
) else (
    echo ✗ ScalpingConfig.mqh not found
)

if exist "Include\RiskManager.mqh" (
    echo ✓ Risk manager found  
) else (
    echo ✗ RiskManager.mqh not found
)

if exist "Include\SignalGenerator.mqh" (
    echo ✓ Signal generator found
) else (
    echo ✗ SignalGenerator.mqh not found
)

if exist "Include\TrailingManager.mqh" (
    echo ✓ Trailing manager found
) else (
    echo ✗ TrailingManager.mqh not found
)
echo.

REM Check documentation
echo [4/5] Checking documentation...
if exist "docs\setup-guide.md" (
    echo ✓ Setup guide found
) else (
    echo ✗ Setup guide not found
)

if exist "docs\strategy-details.md" (
    echo ✓ Strategy documentation found
) else (
    echo ✗ Strategy documentation not found
)

if exist "docs\compilation-guide.md" (
    echo ✓ Compilation guide found  
) else (
    echo ✗ Compilation guide not found
)
echo.

echo [5/5] Next steps:
echo =====================================
echo 1. Copy files to MT5 MQL5 directory:
echo    "%MQL5_PATH%\[Terminal_ID]\MQL5\"
echo.
echo 2. Open MetaEditor (F4 in MT5)
echo.
echo 3. Compile AdaptiveScalpingEA.mq5
echo.
echo 4. Test on demo account first
echo.
echo 5. Check docs\compilation-guide.md for detailed instructions
echo.
echo =====================================
echo Setup check completed!
echo =====================================
pause