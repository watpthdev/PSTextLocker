# Load WPF assembly
Add-Type -AssemblyName PresentationFramework

# Create and configure file dialog
$fileDialog = New-Object Microsoft.Win32.OpenFileDialog
$fileDialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
$fileDialog.Title = "Select a file to encrypt"

# Show dialog and get selected file
$result = $fileDialog.ShowDialog()

if ($result -eq $true) {
    $inputFile = $fileDialog.FileName
} else {
    Write-Host "No file selected. Exiting..." -ForegroundColor Yellow
    exit
}

# Check if file exists
if (-not (Test-Path $inputFile)) {
    Write-Host "File not found: $inputFile" -ForegroundColor Red
    exit
}

# Create save file dialog for output location
$saveDialog = New-Object Microsoft.Win32.SaveFileDialog
$saveDialog.Filter = "Secret files (*.secret)|*.secret|All files (*.*)|*.*"
$saveDialog.Title = "Choose where to save the encrypted file"
$saveDialog.FileName = [System.IO.Path]::GetFileNameWithoutExtension($inputFile) + ".secret"
$saveDialog.DefaultExt = ".secret"
$saveDialog.InitialDirectory = Split-Path $inputFile -Parent

# Show save dialog
$saveResult = $saveDialog.ShowDialog()

if ($saveResult -eq $true) {
    $outputFile = $saveDialog.FileName
} else {
    Write-Host "No output location selected. Exiting..." -ForegroundColor Yellow
    exit
}

$pass = Read-Host "Set password to lock the file" -AsSecureString
$passPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))

$sha256 = New-Object System.Security.Cryptography.SHA256Managed
$key = $sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($passPlain))

$content = Get-Content $inputFile -Raw

$secureString = ConvertTo-SecureString -String $content -AsPlainText -Force
$encryptedContent = ConvertFrom-SecureString -SecureString $secureString -Key $key

$encryptedContent | Set-Content $outputFile
Write-Host "Encryption completed! File saved as $outputFile" -ForegroundColor Green
