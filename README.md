# powershell

## /theme
https://ohmypo.sh/

Themes: C:\Users\daryo\AppData\Local\Programs\oh-my-posh\themes

set new theme:

$ notepad $PROFILE

$ oh-my-posh init pwsh --config 'C:\Users\daryo\AppData\Local\Programs\oh-my-posh\themes\datis-mini.omp.json' | Invoke-Expression

## /script
example:
- split-terminal.bat
- split-terminal.bat 'powershell' 'cmd' 'ubuntu' 'wsl'
- split-terminal.bat 'ubuntu,H,0.7' 'wsl,V,0.3' 'wsl,H,0.5' 'wsl,H,0.5'
