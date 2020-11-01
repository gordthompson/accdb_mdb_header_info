# Copyright 2020 Gordon D. Thompson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$version = "1.0.0"


Function Get-FileName($initialDirectory)
{
    # https://devblogs.microsoft.com/scripting/hey-scripting-guy-can-i-open-a-file-dialog-box-with-windows-powershell/

    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = “All files (*.*)| *.*”
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}


Function pause($message)
{
    # https://stackoverflow.com/a/28237896/2144390

    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else
    {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}


# *** Entry Point to Script ***

$filePath = Get-FileName  -initialDirectory “”
$fileStream = New-Object -TypeName System.IO.FileStream -ArgumentList ($filePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
$fileReader = New-Object -TypeName System.IO.BinaryReader -ArgumentList $fileStream
$filler = $fileReader.ReadBytes(4)
$tagBytes = $fileReader.ReadBytes(15)
$tag = [System.Text.Encoding]::ASCII.GetString($tagBytes)
if (-not (($tag -eq "Standard ACE DB") -or ($tag -eq "Standard Jet DB")))
{
    "WARNING: 'Standard ACE/Jet DB' tag not found."
}
$filler = $fileReader.ReadBytes(1)
$typeCode = $fileReader.ReadBytes(1)
$typeString = "Unknown ($typeCode)"
switch ($typeCode)
{
    0 {$typeString = "Access 97 or older"; Break}
    1 {$typeString = "Access 2000/2003"; Break}
    2 {$typeString = "Access 2007"; Break}
    3 {$typeString = "Access 2010"; Break}
    5 {$typeString = "Access 2016 with BIGINT support (Type 5)"; Break}
}
"File type: $typeString"

if (-not $psISE)
{
    pause "Press any key to continue"
}
