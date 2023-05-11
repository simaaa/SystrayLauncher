class SysTrayForm : System.Windows.Forms.Form {

	hidden [switch]$DebugSettings = $true
	hidden [string]$ConfigFile
	hidden [string]$SystrayTooltipText = [SysTrayForm]
	hidden $Icon
	hidden $NotifyIcon
	hidden $IntfGetIcon
	hidden $IntfConsoleShow
	hidden $IntfConsoleHide
	hidden $Config
	$Settings
	$MenuItems

	SysTrayForm($InvokerFileNameOnly) {
		[SysTrayForm]::DEBUG("Constructor", "InvokerFileNameOnly=$InvokerFileNameOnly");
		$this.ConfigFile = $PSScriptRoot + "\" + $InvokerFileNameOnly + ".json"
		$this.BackColor = "Magenta" #Pick a color you won't use again and match it to the TransparencyKey property
		$this.TransparencyKey = "Magenta"
		$this.ShowInTaskbar = $false
		$this.FormBorderStyle = "None"
		$this.Add_Load( $this.Form_Load )
		$this.Add_Closing( $this.Form_Close )
	}

	$Form_Load = {
		$MethodName = "Form_Load"
		[SysTrayForm]::DEBUG($MethodName, "");
		$this.Text = $this.SystrayTooltipText
		If ( $this.Settings.hide_console ) {
			Invoke-Command $script:SysTrayForm.IntfConsoleHide
		}
	}

	$Form_Close = {
		$MethodName = "Form_Close"
		[SysTrayForm]::DEBUG($MethodName, "");
		If ($script:SysTrayForm.NotifyIcon) {
			$script:SysTrayForm.NotifyIcon.Dispose();
		}
		If ( $this.Settings.hide_console ) {
			Invoke-Command $script:SysTrayForm.IntfConsoleShow
		}
	}

	static
	[Void]
	DEBUG($sender, $text) {
		Write-Host "[$([SysTrayForm]).$sender]  $text"
	}

	[Void]
	DisableDebugSettings() {
		$MethodName = "DisableDebugSettings"
		[SysTrayForm]::DEBUG($MethodName, "");
		$this.DebugSettings = $false
	}

	[string]
	GetSystrayTooltipText() {
		$MethodName = "GetSystrayTooltipText"
		[SysTrayForm]::DEBUG($MethodName, "");
		return $this.SystrayTooltipText;
	}

	[Void]
	AddInterface_Icon($IntfGetIcon) {
		$MethodName = "AddInterface_Icon"
		[SysTrayForm]::DEBUG($MethodName, "");
		$this.IntfGetIcon = $IntfGetIcon
	}

	[Void]
	AddInterface_ConsoleState($IntfConsoleShow, $IntfConsoleHide) {
		$MethodName = "AddInterface_ConsoleState"
		[SysTrayForm]::DEBUG($MethodName, "");
		$this.IntfConsoleShow = $IntfConsoleShow
		$this.IntfConsoleHide = $IntfConsoleHide
	}

	[Void]
	WriteSettings() {
		$MethodName = "DebugSettings"
		[SysTrayForm]::DEBUG($MethodName, "");
		[SysTrayForm]::DEBUG($MethodName, "settings_name             = " + $this.Config.settings_name)
		[SysTrayForm]::DEBUG($MethodName, "tooltip_text              = " + $this.Settings.tooltip_text)
		[SysTrayForm]::DEBUG($MethodName, "systray_icon_file_name    = " + $this.Settings.systray_icon_file_name)
		[SysTrayForm]::DEBUG($MethodName, "systray_icon_index        = " + $this.Settings.systray_icon_index)
		[SysTrayForm]::DEBUG($MethodName, "menu_list_name            = " + $this.Settings.menu_list_name)
		[SysTrayForm]::DEBUG($MethodName, "hide_console              = " + $this.Settings.hide_console)
		[SysTrayForm]::DEBUG($MethodName, "hide_console_handler_menu = " + $this.Settings.hide_console_handler_menu)
	}

	[Void]
	LoadConfig() {
		$MethodName = "LoadConfig"
		[SysTrayForm]::DEBUG($MethodName, "");
		$ContentText = [IO.File]::ReadAllText($this.ConfigFile)
		$this.Config = ConvertFrom-JSON -InputObject $ContentText
	}

	[Void]
	Configure() {
		$this.ConfigureWithSettings($this.Config.settings_name)
	}

	[Void]
	Configure($SettingsName) {
		$MethodName = "Configure"
		[SysTrayForm]::DEBUG($MethodName, "SettingsName=$SettingsName");
		If ( -Not $SettingsName ) { $SettingsName = $this.Config.settings_name }
		$this.Settings = $this.Config | Select -ExpandProperty $SettingsName
		$this.MenuItems = $this.Config | Select -ExpandProperty $this.Settings.menu_list_name
		If ( $this.DebugSettings ) { $this.WriteSettings(); }
		
		If ( $this.Settings.tooltip_text ) { $this.SystrayTooltipText = $this.Settings.tooltip_text }
		If ( -Not $this.Settings ) { Throw "[$MethodName] Not found the settings!"; }
		If ( -Not $this.MenuItems ) { Throw "[$MethodName] Not found the menu items!"; }
		If ( -Not $this.Settings.systray_icon_file_name ) { Throw "[$MethodName] Not found the Systray icon settings! (systray_icon_file_name)"; }
		Try {
			$this.Icon = Invoke-Command $this.IntfGetIcon -ArgumentList ($this.Settings.systray_icon_file_name, $this.Settings.systray_icon_index)
		} Catch {
			Throw "Error while loading icon!`n`n$_"
		}
	}

	[Void]
	ContextMenuItemClick($MenuItemName) {
		$MethodName = "ContextMenuItemClick"
		[SysTrayForm]::DEBUG($MethodName, "MenuItemName = $MenuItemName");
		$Item = $this.MenuItems | Where-Object name -eq $MenuItemName
		try {
			[SysTrayForm]::DEBUG($MethodName, "Launching program: `"$($Item.program)`" $($Item.args)")
			$WorkDir = Split-Path $Item.program -Parent
			If ( -Not $WorkDir ) {
				$WorkDir = $PSScriptRoot
			}
			If ( $Item.args ) {
				Start-Process -WorkingDirectory $WorkDir -FilePath $Item.program -ArgumentList "$($Item.args)" -ErrorAction Stop
			} Else {
				Start-Process -WorkingDirectory $WorkDir -FilePath $Item.program -ErrorAction Stop
			}
		} catch {
			[System.Windows.Forms.MessageBox]::Show("Failed to launch '$($Item.program)'`n`n$_")
		}
	}

	[Void]
	CreateSysTrayIcon() {
		$MethodName = "CreateSysTrayIcon"
		[SysTrayForm]::DEBUG($MethodName, "");
		If ( -Not $this.Icon ) { Throw "[$MethodName] Not found the Systray icon! ($($this.Settings.systray_icon_file_name))" }

		$script:Form = $this
		$this.NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
		$this.NotifyIcon.Icon = $this.Icon
		$this.NotifyIcon.Text = $this.SystrayTooltipText
		$this.NotifyIcon.Visible = $true

		$ContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip
		If ( -Not $this.Settings.hide_console_handler_menu ) {
			$itemShow = $ContextMenuStrip.Items.Add("SysTrayLauncher Console Show")
			$itemShow.image = Invoke-Command $this.IntfGetIcon -ArgumentList ("shell32.dll", 25)
			$itemShow.Add_Click({ Invoke-Command $script:SysTrayForm.IntfConsoleShow })
			$itemHide = $ContextMenuStrip.Items.Add("SysTrayLauncher Console Hide")
			$itemHide.image = Invoke-Command $this.IntfGetIcon -ArgumentList ("shell32.dll", 25)
			$itemHide.Add_Click({ Invoke-Command $script:SysTrayForm.IntfConsoleHide })
			$ContextMenuStrip.Items.Add("-")
		}

		[SysTrayForm]::DEBUG($MethodName, "ADD MENU")
		$this.MenuItems | ForEach-Object -Process {
			[SysTrayForm]::DEBUG($MethodName, "  $(($_).name): $(($_).program) - $(($_).args)")
			If ( ($_).name -Eq "-" ) {
				$item = $ContextMenuStrip.Items.Add( ($_).name )
				return
			}
			$item = New-Object System.Windows.Forms.ToolStripMenuItem(($_).name)
			$item.Add_Click({ $script:Form.ContextMenuItemClick($this); })
			If ( ($_).image_file ) {
				$item.image = Invoke-Command $this.IntfGetIcon -ArgumentList (($_).image_file, ($_).image_index)
			}
			$ContextMenuStrip.Items.Add($item)
		}

		$itemExit = $ContextMenuStrip.Items.Add("Exit")
		$itemExit.image = Invoke-Command $this.IntfGetIcon -ArgumentList ("shell32.dll", 28)
		$itemExit.Add_Click({
			$script:SysTrayForm.Close()
			$script:SysTrayForm.NotifyIcon.Dispose()
		})
		$this.NotifyIcon.ContextMenuStrip = $ContextMenuStrip
	}

}
