@{
    Severity = @('Error', 'Warning', 'Information')

    Rules    = @{
        # Require compatibility w/ PS Core
        PSUseCompatibleCmdlets = @{Compatibility = @("core-6.0.2-windows")}
    }
}
