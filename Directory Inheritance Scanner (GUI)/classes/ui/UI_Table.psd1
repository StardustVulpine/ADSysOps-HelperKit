@{
    # General
    RootModule        = 'UI_Table.psm1'
    ModuleVersion     = '1.0.0'
    Author            = 'Your Name'
    Description       = 'TableLayout class for building UI using WinForms'

    # Export controls
    FunctionsToExport = @()
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    # Dependencies
    RequiredModules   = @("UI_Size.psm1","..\enums\eDockType.ps1","..\enums\eBorder.ps1")
    RequiredAssemblies = @()
}
