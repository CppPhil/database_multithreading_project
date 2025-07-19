#Requires -Version 7.0

$DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BUILD_DIR = Join-Path $DIR "build"
$OUTPUT_FILE = Join-Path $DIR "build_output.txt"

function Print-Help {
    Write-Output @"
Usage: $($MyInvocation.MyCommand.Name) [BUILD_TYPE] [NUM_THREADS] [-G GENERATOR] [-A ARCHITECTURE]

Options:
  BUILD_TYPE     Optional. Specify the build type: Debug (default) or Release.
  NUM_THREADS    Optional. Number of parallel build threads. Defaults to (nproc - 1) or 4.
  -G GENERATOR   Optional. CMake generator (e.g., Ninja, Visual Studio 17 2022).
  -A ARCHITECTURE Optional. Architecture for Visual Studio generators (e.g., Win32, x64, ARM64).

Flags:
  -h, --help     Show this help message and exit.

Examples:
  $($MyInvocation.MyCommand.Name)                            # Debug build, auto threads
  $($MyInvocation.MyCommand.Name) Release                    # Release build, auto threads
  $($MyInvocation.MyCommand.Name) Debug 8                    # Debug build, 8 threads
  $($MyInvocation.MyCommand.Name) Release 4 -G Ninja         # Release build, 4 threads, Ninja
  $($MyInvocation.MyCommand.Name) Debug -G "Visual Studio 17 2022" -A x64  # Debug, VS, x64
"@
    exit 0
}

function Error-Exit {
    param($Message)
    Write-Error $Message
    Pop-Location -ErrorAction SilentlyContinue
    exit 1
}

# Parse arguments
$BUILD_TYPE = "Debug"
$NUM_PROC = $null
$GENERATOR = $null
$ARCHITECTURE = $null
$argsClone = $args.Clone()

for ($i = 0; $i -lt $argsClone.Length; $i++) {
    switch ($argsClone[$i]) {
        {"--help", "-h" -contains $_} { Print-Help }
        "-G" { $i++; $GENERATOR = $argsClone[$i] }
        "-A" { $i++; $ARCHITECTURE = $argsClone[$i] }
        {"Debug", "Release" -contains $_} { $BUILD_TYPE = $argsClone[$i] }
        {$_ -match '^\d+$'} { $NUM_PROC = [int]$argsClone[$i] }
        default { Error-Exit "Invalid argument: $_." }
    }
}

# Validate build type
if ($BUILD_TYPE -notin @("Debug", "Release")) {
    Error-Exit "Invalid build type: $BUILD_TYPE. Expected 'Debug' or 'Release'."
}

# Validate number of threads
if ($null -ne $NUM_PROC) {
    if ($NUM_PROC -le 0) {
        Error-Exit "Invalid number of threads: $NUM_PROC"
    }
} else {
    try {
        $NUM_PROC = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
        if ($null -eq $NUM_PROC -or $NUM_PROC -le 0) { $NUM_PROC = 4 }
        if ($NUM_PROC -gt 1) { $NUM_PROC-- }
    } catch {
        $NUM_PROC = 4
    }
}

# Clean or create build directory
if (Test-Path $OUTPUT_FILE) {
    Remove-Item $OUTPUT_FILE -ErrorAction Stop -Force | Out-Null
}

if (-not (Test-Path $BUILD_DIR)) {
    New-Item -ItemType Directory $BUILD_DIR -ErrorAction Stop | Out-Null
}

Push-Location $BUILD_DIR -ErrorAction Stop

Write-Output ""
Write-Output "This is a $BUILD_TYPE build."
Write-Output "Building with $NUM_PROC threads."
if ($GENERATOR) { Write-Output "Using generator: $GENERATOR" }
if ($ARCHITECTURE) { Write-Output "Architecture: $ARCHITECTURE" }
Write-Output ""

# Build CMake command
$CMAKE_ARGS = @("-DCMAKE_BUILD_TYPE=$BUILD_TYPE")
if ($GENERATOR) { $CMAKE_ARGS += "-G", "`"$GENERATOR`"" }
if ($ARCHITECTURE) { $CMAKE_ARGS += "-A", $ARCHITECTURE }
$CMAKE_ARGS += ".."

# Execute CMake and build
try {
    cmake @CMAKE_ARGS | Tee-Object -FilePath $OUTPUT_FILE -ErrorAction Stop
    if ($LASTEXITCODE -ne 0) { Error-Exit "CMake configuration failed" }
    cmake --build . --parallel $NUM_PROC | Tee-Object -FilePath $OUTPUT_FILE -Append -ErrorAction Stop
    if ($LASTEXITCODE -ne 0) { Error-Exit "CMake build failed" }
} catch {
    Error-Exit $_.Exception.Message
}

Pop-Location -ErrorAction Stop
exit 0
