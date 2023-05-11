# GLOBAL VARIABLES
$FileNameOnly = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$LibFile = $PSScriptRoot + "\" + $FileNameOnly + "_lib.ps1"
$ClassFile = $PSScriptRoot + "\" + $FileNameOnly + "_class.ps1"

# ====================================================================================================
# ADD TYPE AND IMPORT MODULES
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Name Window -Namespace Console -MemberDefinition '
  [DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
Import-Module $LibFile
Import-Module $ClassFile

# ====================================================================================================
# CONFIGURE
Try {
	$SysTrayForm = [SysTrayForm]::New($FileNameOnly)
	#$SysTrayForm.DisableDebugSettings()
	$SysTrayForm.AddInterface_Icon($function:load_icon)
	$SysTrayForm.AddInterface_ConsoleState($function:ConsoleShow, $function:ConsoleHide)
	$SysTrayForm.LoadConfig()
	$SysTrayForm.Configure($args[0])
	$SysTrayForm.CreateSysTrayIcon()
} Catch {
	Write-Error "`n----> $_"
	[System.Windows.Forms.MessageBox]::Show("$_", $MyInvocation.MyCommand.Name) | Out-Null
	RETURN 1
}

# ====================================================================================================
# START
$host.UI.RawUI.WindowTitle = $SysTrayForm.GetSystrayTooltipText()
$SysTrayForm.ShowDialog() > $null

# ====================================================================================================
# END
TIMEOUT /t 2
