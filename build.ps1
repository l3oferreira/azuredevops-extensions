$psModules = ".\tasks\xml\transform\ps_modules\"
$vstsTaskSdkModule = ".\tasks\xml\transform\ps_modules\VstsTaskSdk\"

npm install -g tfx-cli

Remove-item -Recurse -Path $psModules -Force

New-item -ItemType Directory -Path $psModules

Save-Module -Name VstsTaskSdk -Path $psModules

Get-ChildItem -Path $vstsTaskSdkModule | ForEach-Object { Get-ChildItem -Path $_.FullName -Include *.* -Recurse | Move-Item -Destination $vstsTaskSdkModule }

tfx extension create