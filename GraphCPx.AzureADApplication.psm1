function Get-CPxAzureADApplicationInfo
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $ApplicationIDs
    )
    
    $results = @()
    $TenantId = $Credential.UserName.Split('@')[1]

    # Dynamically build the consent URL based on the user's domain name (from UPN) and provided App Id;
    foreach ($applicationId in $ApplicationIds)
    {
        Write-Verbose -Message "Retrieving information for Application ID {$applicationId}"
        $url = "https://login.microsoftonline.com/$tenantId/adminconsent?client_id=$applicationId"
        Write-Verbose -Message "[DYNAMIC URL]: $url"

        # GGenerate a new browser object, and navigate to the app consent's url;
        $ie = New-Object -Com InternetExplorer.Application
        $ie.navigate($url)
        while ($ie.Busy -eq $true) { Start-Sleep -Seconds 1 }

        # Retrieve the option to select the provided account (from Credential param) and simulate a click on it;
        $allDivs = $ie.document.all | Where-Object -FilterScript {$_.TagName -eq 'DIV'}
        $loginDivs = $allDivs        
        $found = $false
        foreach ($div in $allDivs)
        {
            $attributes = $div.attributes
            foreach ($attribute in $attributes)
            {
                if ($attribute.name -eq 'data-test-id' -and $div.attributes["data-test-id"].nodevalue -eq $Credential.UserName)
                {
                    Write-Verbose -Message "Found cached account for {$($Credential.UserName)}"
                    $found = $true
                    $div.click()
                    break
                }
            }
            if ($found)
            {
                break
            }
        }

        # If the account was not cached, we need to show the browser for the user to enter
        # its related info manually;
        if (!$found)
        {
            Write-Host "[WARNING]" -NoNewline -ForegroundColor Yellow
            Write-Host " The Specified account {$($Credential.Username)} is not currently cached. You will need to manually connect using that account for the first time. Once you've connected with that account you will be able to use the cmldet in a true unattended fashion."
            $ie.Visible = $true
            while ($ie.Busy -eq $false) { Start-Sleep -Seconds 1 }
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
        $results += $appInfo
    }
    return $results
 }
