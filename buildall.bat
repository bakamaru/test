@echo on

SET builddir=%~dp0
cd %builddir%nuget
nuget.exe restore ../testApp.sln
cd ../

if exist "testApp.sln" (
	@echo testApp.sln
	"%programfiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe" /verbosity:quiet /nologo /property:Configuration=Release testApp.sln /p:VisualStudioVersion=14.0
        "%programfiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe" /verbosity:quiet /nologo /property:Configuration=Debug testApp.sln /p:VisualStudioVersion=14.0

)

pause
