$codeIconExtractor = @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;

public class IconExtractor {
	public static Icon Extract(string file, int number, bool largeIcon) {
	  IntPtr large;
	  IntPtr small;
	  ExtractIconEx(file, number-1, out large, out small, 1);
	  try {
		return Icon.FromHandle(largeIcon ? large : small);
	  } catch {
		return null;
	  }
	}
	[DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
	private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);
}
"@
Add-Type -TypeDefinition $codeIconExtractor -ReferencedAssemblies System.Drawing

Function load_icon($file, $index) {
	If ( $file.ToUpper().Contains(".DLL") ) {
		return [IconExtractor]::Extract($file, $index, $true);
	} Else {
		return [System.Drawing.Icon]::ExtractAssociatedIcon( $($file) );
	}
}

Function ConsoleShow { [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 5) > $null }
Function ConsoleHide { [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) > $null }
