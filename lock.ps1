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

# Generate output file name (replace extension with .secret)
$directory = Split-Path $inputFile -Parent
$fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($inputFile)
if ([string]::IsNullOrEmpty($directory)) {
    $outputFile = "$fileNameWithoutExt.secret"
} else {
    $outputFile = Join-Path $directory "$fileNameWithoutExt.secret"
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
