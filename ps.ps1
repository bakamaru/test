Clear-Host
 
$_decSep = [System.Threading.Thread]::CurrentThread.CurrentUICulture.NumberFormat.CurrencyDecimalSeparator;
 
$latestmsBuild=$(Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\MSBuild\ToolsVersions\" | 
    Where { $_.Name -match '\\\d+.\d+$' } | 
    Sort-Object -property  @{Expression={[System.Convert]::ToDecimal($_.Name.Substring($_.Name.LastIndexOf("\") + 1).Replace(".",$_decSep).Replace(",",$_decSep))}} -Descending |
    Select-Object -First 1)
$latestmsBuildVersion=([string]$latestmsBuild).split('\')[-1]

$baseDirectory = $PSScriptRoot 
$solutionFilesPath = "$baseDirectory\testApp.sln"
$projectFiles = Get-Content $solutionFilesPath 

$defaultmsBuild = "C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"

$loggerPath="$baseDirectory\buildlog"
$MSBuildLogger="/flp1:Append;LogFile=Build.log;Verbosity=Normal; /flp2:LogFile=BuildErrors.log;Verbosity=Normal;errorsonly"

$msbuild = "${env:ProgramFiles(x86)}\MSBuild\$latestmsBuildVersion\Bin\MSBuild.exe"

$nuget="$baseDirectory\nuget\nuget.exe"
if ((Test-Path -path $nuget)) {
Write-Host "Restoring nuget packages..."
    & $nuget restore $solutionFilesPath
}

if (!(Test-Path -path $loggerPath)) {
md $loggerPath
}

    if ($solutionFilesPath.EndsWith(".sln")) 
    {
        $projectFileAbsPath =$solutionFilesPath # "$baseDirectory\$projectFile"
        
        $filename = [System.IO.Path]::GetFileName($projectFile); 
       
            if(Test-Path $projectFileAbsPath) 
            {
                # Clean the solution
                & $msbuild $projectFileAbsPath /target:clean /p:Configuration=Release

                Start-Sleep -s 2
                Write-Host "Waiting 2 second after clean" -ForegroundColor Red -BackgroundColor White
               
                
                Write-Host "Building $projectFileAbsPath"
                & $msbuild $projectFileAbsPath /verbosity:quiet /nologo /target:build /p:Configuration=Release "/flp1:logfile=$loggerPath\msbuild.log;Verbosity=Normal;Append;" "/flp2:logfile=$loggerPath\errors.txt;errorsonly;Append;"
                #& $devenv $projectFileAbsPath /Rebuild
                
                if($LASTEXITCODE -eq 0)
                {
                    Write-Host "Build SUCCESS" -ForegroundColor Green
                   # Clear-Host
                    break
                }
                else
                {
                    Write-Host "Build FAILED" -ForegroundColor Red
                  
                }
            }
            else
            {
                Write-Host "File does not exist : $projectFileAbsPath"
                Start-Sleep -s 5
              
            }
       
        
    }
