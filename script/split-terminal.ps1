<#
.SYNOPSIS
    Launches Windows Terminal with multiple panes, custom commands/profiles, and split sizes.

.EXAMPLE
    .\split-terminal.ps1 `
        -Panes @(
            @{ Command = "pwsh";       Direction = "H"; Size = 0.5 },
            @{ Command = "cmd";        Direction = "V"; Size = 0.5 },
            @{ Command = "Ubuntu";     Direction = "H"; Size = 0.5 }
        )

    This opens:
    - Pane 0: PowerShell 7
    - Pane 1: CMD (vertical split from Pane 0, 50% size)
    - Pane 2: Ubuntu (horizontal split from Pane 1, 50% size)
#>

# Capture all arguments from batch
$ArgsFromBatch = $args

function DefaultLayout {
    # Start with top-left pane
    $cmds = @()

    # Step 1: Split horizontally (left/right)
    $cmds += 'pwsh -NoExit -command cls'
    $cmds += 'split-pane -H --size 0.5 cmd /K cls'

    # Step 2: Focus left pane and split vertically
    $cmds += 'focus-pane -t 0'
    $cmds += 'split-pane -V --size 0.5 wsl -d Ubuntu -- bash -c "cd && clear && exec bash"'

    # Step 3: Focus right pane and split vertically
    $cmds += 'focus-pane -t 1'
    $cmds += 'split-pane -V --size 0.5 Ubuntu run "cd && clear && exec bash"'

    $cmds += 'focus-pane -t 0'
    Start-Process wt.exe ($cmds -join ' ; ')
}

# If no args passed, use defaults
if (-not $ArgsFromBatch -or $ArgsFromBatch.Count -eq 0) {
    # $Panes = @(
    #     @{ Command = 'pwsh -NoExit -command cls'; Direction = 'H'; Size = 0.5 },
    #     @{ Command = 'cmd /K cls'; Direction = 'H'; Size = 0.5 },
    #     @{ Command = 'focus-pane -t 0 ; wsl -d Ubuntu -- bash -c "cd && clear && exec bash"'; Direction = 'V'; Size = 0.5 },
    #     @{ Command = 'focus-pane -t 1 ; Ubuntu run "cd && clear && exec bash"'; Direction = 'V'; Size = 0.5 }
    # )
    DefaultLayout
    exit
}
else {
    # Build panes dynamically from arguments
    $Panes = @()

    foreach ($arg in $ArgsFromBatch) {
        $parts = $arg -split '[,]'  # split on comma
        $cmd = $parts[0]
        $dir = if ($parts.Count -gt 1) { $parts[1] } else { "H" }
        $size = if ($parts.Count -gt 2) { [double]$parts[2] } else { 0.5 }
        
        # Special handling for known keywords
        switch -Regex ($cmd.ToLower()) {
            "ubuntu" { $cmd = 'Ubuntu run "cd && clear && exec bash"' }
            "wsl" { $cmd = 'wsl -d Ubuntu -- bash -c "cd && clear && exec bash"' }
            "cmd" { $cmd = 'cmd /K cls' }
            "powershell" { $cmd = 'pwsh -NoExit -command cls' }
            default { $cmd }
        }

        $Panes += @{
            Command   = $cmd
            Direction = $dir
            Size      = $size
        }
    }
}

try {
    # Ensure Windows Terminal CLI is available
    if (-not (Get-Command wt.exe -ErrorAction SilentlyContinue)) {
        throw "Windows Terminal (wt.exe) not found. Please install or update Windows Terminal."
    }

    if ($Panes.Count -eq 0) {
        throw "No pane definitions provided."
    }

    # Start building the command sequence
    $wtCommandParts = @()

    # First pane (no split)
    $wtCommandParts += $Panes[0].Command

    # Remaining pane(s)
    for ($i = 1; $i -lt $Panes.Count; $i++) {
        $pane = $Panes[$i]

        # Validate direction
        if ($pane.Direction -notin @("H", "V")) {
            throw "Invalid Direction for pane $i. Use 'H' or 'V'."
        }

        # Validate size
        if ($pane.Size -lt 0.1 -or $pane.Size -gt 0.9) {
            throw "Invalid Size for pane $i. Must be between 0.1 and 0.9."
        }

        # Build split command
        $splitCmd = "focus-tab -t 0 ; split-pane -$($pane.Direction) --size $($pane.Size) $($pane.Command)"
        $wtCommandParts += $splitCmd
    }

    # Sets focus on first pane
    $splitCmd = "focus-pane -t 0"
    $wtCommandParts += $splitCmd

    # Join commands with semicolons
    $wtCommand = $wtCommandParts -join ' ; '

    # Launch Windows Terminal
    Start-Process wt.exe $wtCommand

} catch {
    Write-Error $_
}
