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
$saveDialog.Filter = "PDF files (*.pdf)|*.pdf|All files (*.*)|*.*"
$saveDialog.Title = "Choose where to save the encrypted PDF file"
$saveDialog.FileName = [System.IO.Path]::GetFileNameWithoutExtension($inputFile) + "_encrypted.pdf"
$saveDialog.DefaultExt = ".pdf"
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

# Generate output file paths
$secretFile = [System.IO.Path]::ChangeExtension($outputFile, ".secret")

# Save .secret file
$encryptedContent | Set-Content $secretFile
Write-Host "Secret file saved as $secretFile" -ForegroundColor Cyan

# Create Word COM object to generate PDF
$word = New-Object -ComObject Word.Application
$word.Visible = $false

try {
    # Create new document
    $doc = $word.Documents.Add()

    # Add encrypted content to document
    $selection = $word.Selection
    $selection.Font.Name = "Courier New"
    $selection.Font.Size = 10
    $selection.TypeText($encryptedContent)

    # Save as PDF (wdFormatPDF = 17)
    $doc.SaveAs([ref]$outputFile, [ref]17)

    # Close document without saving changes (since already saved as PDF)
    $doc.Close([ref]$false)

    Write-Host "--------------------------------" -ForegroundColor Green
    Write-Host "✓ Encryption completed!" -ForegroundColor Green
    Write-Host "Files saved:" -ForegroundColor Cyan
    Write-Host "  - Secret: $secretFile" -ForegroundColor Yellow
    Write-Host "  - PDF: $outputFile" -ForegroundColor Yellow
    Write-Host "--------------------------------" -ForegroundColor Green
}
catch {
    Write-Host "Error occurred: $_" -ForegroundColor Red
}
finally {
    # Clean up Word COM object
    if ($doc) {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
    }
    if ($word) {
        $word.Quit([ref]$false)
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Remove-Variable word, doc -ErrorAction SilentlyContinue
}
