#
# Module manifest for module 'Graph CPx'
#
# Generated by: Graph CPx Team
#
# Generated on: 02/24/2021
#
@{
    ModuleVersion = '1.0.0.1'
    GUID = '704deea9-0582-48e2-91bb-ac6dd798f317'
    Author = 'Microsoft Corporation'
    CompanyName = 'Microsoft Corporation'
    Copyright = '(c) 2015-2021 Microsoft Corporation. All rights reserved.'
    Description = 'Set of PowerShell Utility functions used by the Graph CPx team.'
    PowerShellVersion = '4.0'
    NestedModules = @("GraphCPx.AzureADApplication.psm1")
    CmdletsToExport = @()
    FunctionsToExport = @("Get-CPxAzureADApplicationInfo")
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{

            Tags = @('MicrosoftGraph')

            # A URL to the license for this module.
            LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://Github.com/Microsoft/GraphCPx'

            # A URL to an icon representing this module.
            IconUri = 'https://github.com/microsoft/GraphCPx/raw/main/Images/PowerShellGraphSDK.png?raw=true'

            ReleaseNotes = '
            * Major cleanup of solution and refactoring of help content;'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
