shell = WScript.createObject("WScript.Shell");
ret = shell.Run("\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" -NoProfile -ExecutionPolicy RemoteSigned -File \"" + WScript.Arguments.Item(0) + "\"", 0, true);
WScript.Quit(ret);
