<div align="center">

# PSSslLookup

Fetch information about certificates presented by web servers.

</div>

## Installation

*PSSslLookup* is available on the PowerShell Gallery. Use the following command to install the it:

```powershell
Install-Module -Name PSSslLookup -Scope CurrentUser
```

## Usage

To get information about a certificate:

```powershell
Get-SslCertificate -Uri 'github.com'

Subject      : CN=github.com
IssuedOn     : 07/03/2024 01:00:00
ExpiresOn    : 08/03/2025 00:59:59
Issuer       : CN=Sectigo ECC Domain Validation Secure Server CA, O=Sectigo
               Limited, L=Salford, S=Greater Manchester, C=GB
SerialNumber : 4E28F786B66C1A3B942CD2C40EB742A5
Thumbprint   : E7035BCC1C18771F792F90866B6C1DF8DFAABDC0
```

Export a certificate to a file:

```powershell
$CertObject = Get-SslCertificate -IncludeCertificate -Uri 'github.com'
Export-Certificate -Cert $CertObject.Certificate -FilePath /temp/github.com.cer
```

## Parameters
- `-Uri`: The URI of the server from which to retrieve the SSL certificate.
- `-Port`: The port number to connect to (default is 443).
- `-IncludeCertificate`: A switch parameter that, when specified, includes the full SSL certificate object in the output.
- `-IPAddress`: An optional parameter to specify the IP address of the server. This parameter is validated to ensure it is a valid IP address.
