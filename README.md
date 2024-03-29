# Systray launcher for windows
<p align="center">
	<img alt="aa" src="https://github.com/simaaa/SystrayLauncher/blob/main/screenshot_demo.jpg" width="200" height="200">
	<img alt="bb" src="https://github.com/simaaa/SystrayLauncher/blob/main/screenshot_ora.jpg" width="200" height="200">
	<img alt="cc" src="https://github.com/simaaa/SystrayLauncher/blob/main/screenshot_git.jpg" width="200" height="200">
	<img alt="cc" src="https://github.com/simaaa/SystrayLauncher/blob/main/screenshot_submenu.jpg" width="200" height="200">
</p>

## Description
Systray launcher is PowerShell script that creates an icon on your windows tray for customized context menu to launch programs very quickly. The menu items are read from the json configuration file.

## Configuration
```JSON
{
	"settings_name" : "settings_demo",
	"settings_demo" : {
		"tooltip_text" : "SysTrayLauncher",
		"systray_icon_file_name" : "shell32.dll",
		"systray_icon_index" : "317",
		"menu_list_name" : "menu_items_demo",
		"hide_console" : false,
		"hide_console_handler_menu" : false
	},
	"menu_items_demo" : [
		{ "name" : "notepad", "program" : "notepad.exe", "args" : "\"teszt.txt\"", "image_file" : "shell32.dll", "image_index" : "42" },
		{ "name" : "demo.cmd", "program" : ".\\demo.cmd", "args" : "arg1, arg2", "image_file" : "shell32.dll", "image_index" : "42" },
		{ "name" : "PowerShell Script", "program" : "powershell.exe", "args" : "Write-Host \"OK\"; TIMEOUT /t 3;", "image_file" : "shell32.dll", "image_index" : "42" },
		{ "name" : "PowerShell File", "program" : "powershell.exe", "args" : "-File \".\\demo.ps1\"", "image_file" : "shell32.dll", "image_index" : "42" },
		{ "name" : "PLSQL Developer 15", "program" : "C:\\Program Files\\PLSQL Developer 15\\plsqldev.exe", "args" : "", "image_file" : "C:\\Program Files\\PLSQL Developer 15\\plsqldev.exe", "image_index" : "" },
		{ "name" : "-", "program" : "", "args" : "", "image_file" : "", "image_index" : "" },
		{ "name" : "Sleep", "program" : "powershell.exe", "args" : "Write-Host \"Starting sleep...\"; TIMEOUT /t 3;", "image_file" : "imageres.dll", "image_index" : "97" },
		{ "name" : "-", "program" : "", "args" : "", "image_file" : "", "image_index" : "" },
		{ "name" : "Submenu-A", "program" : "", "args" : "", "image_file" : "shell32.dll", "image_index" : "42"
			,"submenu":[
				{ "name" : "A-11", "program" : "powershell.exe", "args" : "Write-Host \"...11...\"; TIMEOUT /t 3;", "image_file" : "shell32.dll", "image_index" : "25" },
				{ "name" : "A-22", "program" : "powershell.exe", "args" : "Write-Host \"...22...\"; TIMEOUT /t 3;", "image_file" : "shell32.dll", "image_index" : "25" }
			]
		},
		{ "name" : "Submenu-B", "program" : "", "args" : "", "image_file" : "shell32.dll", "image_index" : "42"
			,"submenu":[
				{ "name" : "B-33", "program" : "powershell.exe", "args" : "Write-Host \"...33...\"; TIMEOUT /t 3;", "image_file" : "shell32.dll", "image_index" : "25" },
				{ "name" : "B-44", "program" : "powershell.exe", "args" : "Write-Host \"...44...\"; TIMEOUT /t 3;", "image_file" : "shell32.dll", "image_index" : "25" }
			]
		},
		{ "name" : "-", "program" : "", "args" : "", "image_file" : "", "image_index" : "" }
	]
}
```

#### Application parameters
- tooltip_text: Tooltip text on the systray icon.
- systray_icon_file_name: The file containing the tray icon.
- systray_icon_index: The item index in the systray icon file.
- menu_list_name: Loadable menu item list in the configuration file.
- hide_console: Hide PowerShell console on startup. (true/false)
- hide_console_handler_menu: Hide PowerShell console show and hide menu items. (true/false)

#### Menu item parameters
- name: Menu item name
- program: Command to run
- args: Command arguments
- image_file: Menu item icon file
- image_index: Index of icon file in dll

## Prerequisites
#### PowerShell Execution Policy configuration
<img src="https://www.freeiconspng.com/uploads/powershell-icon-3.png" width="50" alt="Powershell" />

```
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```

## Start
```
PS .\systray_launcher.ps1
```
## Start with settings name parameter
#### Create startup script file and call with settings name parameter
```
.\systray_launcher.ps1 <settings_name>
```
```
.\systray_launcher.ps1 menu_items_demo
```

