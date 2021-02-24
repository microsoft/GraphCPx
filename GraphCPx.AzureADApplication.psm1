function Get-CPxAzureADApplicationInfo
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationId
    )
    
    # Dynamically build the consent URL based on the user's domain name (from UPN) and provided App Id;
    $TenantId = $Credential.UserName.Split('@')[1]
    $url = "https://login.microsoftonline.com/$tenantId/adminconsent?client_id=$ApplicationId"
    Write-Verbose -Message "[DYNAMIC URL]: $url"

    # GGenerate a new browser object, and navigate to the app consent's url;
    $ie = New-Object -Com InternetExplorer.Application
    $ie.navigate($url)
    while ($ie.Busy -eq $true) { Start-Sleep -Seconds 1 }

    # Retrieve the option to select the provided account (from Credential param) and simulate a click on it;
    $allDivs = $ie.document.all | Where-Object -FilterScript {$_.TagName -eq 'DIV'}
    $loginDivs = $allDivs
    foreach ($div in $allDivs)
    {
        $attributes = $div.attributes
        $found = $false
        foreach ($attribute in $attributes)
        {
            if ($attribute.name -eq 'data-test-id' -and $div.attributes["data-test-id"].nodevalue -eq $Credential.UserName)
            {
                $div.click()
                break
            }
        }
    }
    while ($ie.Busy -eq $true) { Start-Sleep -Seconds 1 }

    # Retrieve a list of all permissions required by the app;
    $requiredPermissions = @()
    $allPermissions = $ie.document.all | Where-Object -FilterScript {$_.TagName -eq 'DIV' -and $_.className -eq "label text-13"}
    foreach ($permission in $allPermissions)
    {
        $requiredPermissions += $permission.textContent
    }

    # From the consent page, retrieve information about the app's name, required consent, etc.
    $appInfo = @{
        ApplicationName     = ($ie.document.all | Where-Object -FilterScript {$_.TagName -eq 'DIV' -and $_.className -eq "row app-name"}).textContent
        RequiredPermissions = $requiredPermissions
    }
    $ie.Quit()

    # Returned the compiled information as a Hashtable to the user;
    return $appInfo
 }
