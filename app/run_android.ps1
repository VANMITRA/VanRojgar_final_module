Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " VanRozgar Android Build & Launch Script " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Reverse port 3000 for local backend connection
Write-Host "[1/5] Setting up ADB port forwarding (tcp:3000)..." -ForegroundColor Yellow
adb reverse tcp:3000 tcp:3000

# 2. Enforce PUB_CACHE on D: drive to eliminate Windows cross-drive C: vs D: root errors
$env:PUB_CACHE = "D:\VanRozgar\.pub-cache"
Write-Host "[2/5] PUB_CACHE set to: $env:PUB_CACHE" -ForegroundColor Green

# 3. Clean any corrupted build cache files
Write-Host "[3/5] Cleaning old build artifacts..." -ForegroundColor Yellow
flutter clean

# 4. Fetch dependencies into D: drive pub cache
Write-Host "[4/5] Fetching Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

# 5. Stop any lingering background Gradle daemons
if (Test-Path "android\gradlew.bat") {
    Write-Host "[5/5] Stopping stale Gradle daemons..." -ForegroundColor Yellow
    cmd /c "android\gradlew.bat --stop"
}

Write-Host "Starting Flutter Run on connected device..." -ForegroundColor Cyan
flutter run --android-skip-build-dependency-validation
