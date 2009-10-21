WinGrowl.exe - The Growl Server implementation.
	This is a very simple implementation, there are no per-application controls
	yet, all you get are the popups when a valid Growl packet is received.

WinGrowlCLI.exe - A command-line WinGrowl client.
	This application allows scripts and programs to add support for Growl
	without learning the protocol. Simply call the application with the right
	parameters and it'll send a notification for you. Run it with a "/?"
	parameter to get help.

LibWinGrowl.dll - DLL for developers that want to add Growl notifications to their apps.
