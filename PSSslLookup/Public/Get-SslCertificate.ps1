<#
.SYNOPSIS
Retrieves SSL certificate information from a specified URI and port.

.DESCRIPTION
The Get-SslCertificate function establishes a TCP connection to the specified URI and port, retrieves the SSL certificate, and provides detailed information about the certificate, including its subject, issuer, validity period, serial number, thumbprint, and extensions. Optionally, the full certificate object can be included in the output.

.PARAMETER Uri
The URI of the server from which to retrieve the SSL certificate.

.PARAMETER Port
The port number to connect to (default is 443).

.PARAMETER IncludeCertificate
A switch parameter that, when specified, includes the full SSL certificate object in the output.

.PARAMETER IPAddress
An optional parameter to specify the IP address of the server. This parameter is validated to ensure it is a valid IP address.

.EXAMPLE
Get-SslCertificate -Uri "www.example.com" -IncludeCertificate

.EXAMPLE
Get-SslCertificate -Uri "www.example.com" -Port 8443

#>

Function Get-SslCertificate {
	[CmdletBinding(DefaultParameterSetName = 'ByUri')]
    param(
    	[Parameter(Mandatory, ParameterSetName = 'ByUri', Position = 0)]
    	[String]$Uri,

        [Parameter(Mandatory, ParameterSetName = 'ByIP', Position = 0)]
        [ValidateScript({[ipaddress]($_ -replace '^https://')})]
        [String]$IPAddress,

        [Int]$Port = 443,
        [Switch]$IncludeCertificate
    )

    # Decide between Uri and IpAdress and remove scheme
    $Endpoint = switch ($PSCmdlet.ParameterSetName) {
    	'ByUri' { $Uri -replace '^https://' }
    	'ByIP' { $IPAddress.IPAddressToString -replace '^https://' }
    }

    Write-Verbose "Create TcpClient and SslStream and connect to $($Endpoint):$Port"
    $TcpClient = New-Object -TypeName System.Net.Sockets.TcpClient -ArgumentList $Endpoint, $Port
    $SslStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList $TcpClient.GetStream(), $false, { $true }

    Write-Verbose "Authenticate as client"
    Try {
    	$SslStream.AuthenticateAsClient($Endpoint)
    	Write-Verbose "Authenticated successfully"

    } Catch {
    	Write-Verbose "Could not authenticate to $($Endpoint):$Port"
    	Return
    }

    $Certificate = $SslStream.RemoteCertificate

    $Extensions = Foreach($Extension in $Certificate.Extensions) {
        $AsnEncodedData = [System.Security.Cryptography.AsnEncodedData]::new($Extension.Oid, $Extension.RawData)

        $ExtensionsObject = [pscustomobject]@{
            ExtensionType  = $Extension.Oid.FriendlyName
            OidValue       = $Extension.Oid.Value
            RawDataLength  = $AsnEncodedData.RawData.Length
            ExtensionValue = $AsnEncodedData.Format($true)
        }

        $DefaultDisplaySet = 'ExtensionType', 'ExtensionValue'
        $DefaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $ExtensionsObject| Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers

        $ExtensionsObject.PSObject.TypeNames.Insert(0, 'Extension.Information')

        Write-Output $ExtensionsObject
    }

    $CertObject = [pscustomobject]@{
        Subject      = $Certificate.Subject
        IssuedOn   = $Certificate.NotBefore
        ExpiresOn   = $Certificate.NotAfter
        Issuer       = $Certificate.Issuer
        SerialNumber = $Certificate.SerialNumber
        Thumbprint   = $Certificate.Thumbprint
        Extensions   = $Extensions
        Request      = @{
            TcpHost      = $Endpoint
        }
    }

    If($IncludeCertificate.IsPresent) {
        $CertObject | Add-Member -MemberType NoteProperty -Name 'Certificate' -Value $Certificate
    }

    $DefaultDisplaySet = 'Subject', 'IssuedOn', 'ExpiresOn', 'Issuer', 'SerialNumber', 'Thumbprint'
    $DefaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    $CertObject| Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers

    $CertObject.PSObject.TypeNames.Insert(0, 'Certificate.Information')

    Write-Output $CertObject
}
