@echo off
REM ================================================================
REM  export_stls.bat — Render all pancake motor parts to STL files
REM  Usage:  export_stls.bat [output_dir]
REM  Requires: OpenSCAD installed, openscad.exe on PATH
REM            Default install: C:\Program Files\OpenSCAD\openscad.exe
REM ================================================================

setlocal enabledelayedexpansion

set SCAD=pancake_motor_assembly.scad
set OUTDIR=%~1
if "%OUTDIR%"=="" set OUTDIR=stl_output

REM  Adjust this path if openscad.exe is not on PATH
set OPENSCAD=openscad
where %OPENSCAD% >nul 2>&1
if errorlevel 1 (
    set OPENSCAD=C:\Program Files\OpenSCAD\openscad.exe
)

if not exist "%SCAD%" (
    echo ERROR: %SCAD% not found in current directory.
    exit /b 1
)

if not exist "%OPENSCAD%" (
    echo ERROR: openscad not found. Install from https://openscad.org/downloads.html
    echo        or add openscad.exe to PATH.
    exit /b 1
)

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

echo Using: %OPENSCAD%
echo Source: %SCAD%
echo Output: %OUTDIR%\
echo.

set PASS=0
set FAIL=0

REM ── Parts list ──────────────────────────────────────────────────
set PARTS=shaft rotor_disc housing_front housing_rear front_end_cap rear_end_cap

for %%P in (%PARTS%) do (
    set OUTFILE=%OUTDIR%\%%P.stl
    <nul set /p "=  Rendering %%P -> !OUTFILE! ... "

    "%OPENSCAD%" --quiet -o "!OUTFILE!" -D "PART=\"%%P\"" -D "EXPLODE=0" "%SCAD%" 2>nul

    if !errorlevel! equ 0 (
        echo OK
        set /a PASS+=1
    ) else (
        echo FAILED
        set /a FAIL+=1
    )
)

echo.
echo =======================================
set /a TOTAL=%PASS%+%FAIL%
echo   Rendered : %PASS% / %TOTAL% parts
echo   Output   : %OUTDIR%\
echo =======================================
echo.
echo Note: rotor_disc.stl is used for BOTH rotors. Print or machine two copies.
echo       housing_front + housing_rear sandwich the PCB — both required.
