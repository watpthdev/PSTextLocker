# Text File Encryption Tool

A PowerShell-based file encryption and decryption utility designed to securely hide sensitive content in text files using password protection.

## Overview

This tool provides a simple and secure way to encrypt and decrypt `.txt` files, converting them to password-protected `.secret` files. It uses SHA-256 hashing for password derivation and AES encryption for content protection.

## Features

- 🔒 **Password-Protected Encryption** - Secure your text files with a password
- 🔓 **Easy Decryption** - Decrypt files using the same password
- 🖱️ **GUI File Picker** - Modern WPF-based file selection dialog with high DPI support
- ✅ **File Validation** - Automatic file type checking
- ⚡ **Fast & Lightweight** - Pure PowerShell implementation, no external dependencies
- 🎨 **Styled Error Messages** - Clear, formatted error messages for better UX

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- .NET Framework (included with Windows)

## Installation

1. Clone or download this repository
2. No additional installation required - the scripts are ready to use

## Usage

###
COMMIT 2

### Encrypting a File (lock.ps1)

1. Run the script:
   ```powershell
   .\lock.ps1
   ```

2. A file picker dialog will appear - select the `.txt` file you want to encrypt

3. Enter a password when prompted (characters won't be visible for security)

4. The encrypted file will be saved with a `.secret` extension in the same directory
   - Example: `myfile.txt` → `myfile.secret`

### Decrypting a File (unlock.ps1)

1. Run the script:
   ```powershell
   .\unlock.ps1
   ```

2. A file picker dialog will appear - select the `.secret` file you want to decrypt

3. Enter the password you used during encryption

4. The decrypted content will be displayed in the terminal

**Note:** The original `.secret` file remains unchanged after decryption.

## How It Works

### Encryption Process (lock.ps1)

1. Prompts user to select a `.txt` file via GUI
2. Requests a password (stored securely)
3. Generates a 256-bit encryption key using SHA-256 hash of the password
4. Encrypts the file content using AES encryption
5. Saves the encrypted content as a `.secret` file

### Decryption Process (unlock.ps1)

1. Prompts user to select a `.secret` file via GUI
2. Requests the password
3. Generates the same encryption key from the password
4. Decrypts the file content
5. Displays the original text in the terminal

## Security Features

- **SHA-256 Password Hashing** - Passwords are hashed using SHA-256 before use
- **AES Encryption** - Uses PowerShell's built-in ConvertFrom-SecureString with AES
- **Secure Password Input** - Passwords are never displayed on screen
- **Memory Protection** - Uses SecureString for password handling

## File Structure

```
.
├── lock.ps1              # Encryption script
├── unlock.ps1            # Decryption script
├── .gitignore            # Git ignore rules (excludes .txt and .secret files)
├── .gitattributes        # Git line ending configuration (CRLF)
├── .editorconfig         # Editor configuration for consistent formatting
└── README.md             # This file
```

## Examples

### Example Workflow

```powershell
# Encrypt a file
PS> .\lock.ps1
# Select "passwords.txt" from file picker
# Enter password: ********
# Output: Encryption completed! File saved as passwords.secret

# Decrypt the file
PS> .\unlock.ps1
# Select "passwords.secret" from file picker
# Enter password: ********
# Output: Your data is:
#         [decrypted content displayed here]
```

### Error Handling

If you enter an incorrect password:

```
╔════════════════════════════════════════════════════════╗
║                                                        ║
║             ❌ DECRYPTION FAILED ❌                    ║
║                                                        ║
║  Incorrect password or the file may be corrupted.      ║
║  Please verify your password and try again.            ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

## Important Notes

⚠️ **Password Recovery**: There is no way to recover a forgotten password. Make sure to remember or securely store your passwords.

⚠️ **File Backup**: Always keep a backup of your original files before encryption.

⚠️ **Security Limitation**: While this tool provides good encryption for hiding content, it should not be considered enterprise-grade security. For highly sensitive data, consider using professional encryption tools.

## Development

### Code Style

- Follows PowerShell best practices
- 4-space indentation (as defined in `.editorconfig`)
- CRLF line endings for Windows compatibility

### Git Configuration

- `.txt` and `.secret` files are excluded from version control
- Line endings are normalized to CRLF via `.gitattributes`

## License

This project is provided as-is for educational and personal use.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

---

**Made with PowerShell** 💙
