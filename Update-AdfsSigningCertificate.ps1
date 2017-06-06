[CmdletBinding()]param(
    [Parameter(Mandatory=$true)]
    $FederationServer,

    [Parameter(Mandatory=$true)]
    $TrustedProvider,

    [Switch]
    $DryRun
)

# We need this module
# Link: https://gallery.technet.microsoft.com/scriptcenter/AD-FS-Diagnostics-Module-8269de31

Import-Module .\ADFSDiagnostics.psm1 -ErrorAction SilentlyContinue -ErrorVariable moduleError

if ($moduleError) {
    Write-Error "There was an error loading the module ADFSDiagnostics. Make sure ADFSDiagnostics.psm1 is in the same folder as the script. You can download it from https://gallery.technet.microsoft.com/scriptcenter/AD-FS-Diagnostics-Module-8269de31"    
    return
}

# 1. Use the ADFS Diagnostics to request a Security Token. We will get the primary signing certificate from there
$adfsProvider = Get-SPTrustedIdentityTokenIssuer $TrustedProvider -ErrorAction SilentlyContinue -ErrorVariable "myErrors"
if ($myErrors -ne $null) {
    $msg = $myErrors[0].Exception.Message
    Write-Error "Could not get the ADFS Trusted Provider in SharePoint: $msg"
    return
}

$adfsRealm = $adfsProvider.DefaultProviderRealm

try {
    [xml]$token = Test-AdfsServerToken -FederationServer $FederationServer -AppliesTo $adfsRealm
    $newCertBase64 = $token.Envelope.Body.RequestSecurityTokenResponse.RequestedSecurityToken.Assertion.Signature.KeyInfo.X509Data.InnerText
    $newCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $newCert.Import([System.Text.Encoding]::UTF8.GetBytes($newCertBase64))
    Write-Host "Primary ADFS Signing cert subject: $($newCert.Subject) Thumbprint: $($newCert.Thumbprint)"
}
catch {
    Write-Error "There was an error getting the security token from ADFS: $($_)"
    return
}

# 2. Compare the current certificate in the Trusted Provider with the primary certificate
#    if they are different, then update the certificate in the Trusted Provider
if ($newCert.Thumbprint -ne $null -and -not $adfsProvider.SigningCertificate.Equals($newCert)) {
    # Do we need to add the new cert as CA in SharePoint?
    if ((Get-SPTrustedRootAuthority | ? {$_.Certificate.Thumbprint -eq $newCert.Thumbprint}) -eq $null) {
        Write-Host "Adding the ADFS cert" $newCert.Subject "to the SharePoint trust store"
        if ($DryRun) {
            Write-Warning "DryRun: not adding the certificate"
        }
        else {
            New-SPTrustedRootAuthority -Name $newCert.Subject -Certificate $newCert
        }
    }
    else {
        Write-Warning "NOT adding the ADFS cert $($newCert.Subject) to the SharePoint trust store because it is already there"
    }

    # Set the cert in the Trusted Provider
    Write-Host "Setting the certificate in the ADFS Trusted Provider"
    if ($DryRun) {
        Write-Warning "DryRun: not changing the certificate in the Trusted Provider"
    }
    else {
        $adfsProvider | Set-SPTrustedIdentityTokenIssuer -ImportTrustCertificate $newCert
    }
}
else {
    Write-Warning "The ADFS primary certificate is already the same as in the SharePoint ADFS Trusted Provider"
}
