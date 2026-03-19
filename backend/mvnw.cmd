@REM Maven Wrapper script for Windows
@echo off
setlocal

set MAVEN_WRAPPER_PROPERTIES=.mvn\wrapper\maven-wrapper.properties
set MAVEN_HOME=%USERPROFILE%\.m2\wrapper\dists

for /f "tokens=2 delims==" %%a in ('findstr "distributionUrl" %MAVEN_WRAPPER_PROPERTIES%') do set distributionUrl=%%a

for /f "tokens=1 delims=-" %%a in ('echo %distributionUrl%') do set version=%%a
REM Extract version from URL
for /f "delims=" %%v in ('powershell -Command "('%distributionUrl%' -match 'apache-maven-([\d.]+)') | Out-Null; $matches[1]"') do set version=%%v

set MAVEN_DIST_DIR=%MAVEN_HOME%\apache-maven-%version%

if not exist "%MAVEN_DIST_DIR%" (
    echo Downloading Maven %version%...
    if not exist "%MAVEN_HOME%" mkdir "%MAVEN_HOME%"
    powershell -Command "Invoke-WebRequest -Uri '%distributionUrl%' -OutFile '%TEMP%\maven.zip'"
    powershell -Command "Expand-Archive -Path '%TEMP%\maven.zip' -DestinationPath '%MAVEN_HOME%' -Force"
    del "%TEMP%\maven.zip"
    echo Maven %version% installed.
)

set MAVEN_HOME=%MAVEN_DIST_DIR%
set PATH=%MAVEN_HOME%\bin;%PATH%
mvn %*
