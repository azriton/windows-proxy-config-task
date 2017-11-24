$PROXY_HOST="proxy.example.com"
$PROXY_PORT=8080
$LOCAL_ADDR="<local>"

$REG_KEY="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"

try {
    $ignore = [System.Net.Dns]::GetHostAddresses(${PROXY_HOST}) | ? { $_.AddressFamily -eq "InterNetwork" }

    Set-ItemProperty -path ${REG_KEY} ProxyEnable -value 1
    Set-ItemProperty -path ${REG_KEY} ProxyServer -value "${PROXY_HOST}:${PROXY_PORT}"
    Set-ItemProperty -path ${REG_KEY} ProxyOverride -value ${LOCAL_ADDR}
    Set-Item -path env:HTTP_PROXY -value "http://${PROXY_HOST}:${PROXY_PORT}"
    Set-Item -path env:HTTPS_PROXY -value ${env:HTTP_PROXY}
    [Environment]::SetEnvironmentVariable("HTTP_PROXY", ${env:HTTP_PROXY}, [EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("HTTPS_PROXY", ${env:HTTP_PROXY}, [EnvironmentVariableTarget]::User)
} catch {
    Set-ItemProperty -path ${REG_KEY} ProxyEnable -value 0
    Remove-Item -path env:HTTP_PROXY
    Remove-Item -path env:HTTPS_PROXY
    [Environment]::SetEnvironmentVariable("HTTP_PROXY", "", [EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("HTTPS_PROXY", "", [EnvironmentVariableTarget]::User)
}

$source=@"
[DllImport("wininet.dll")]
public static extern bool InternetSetOption(int hInternet, int dwOption, int lpBuffer, int dwBufferLength);
"@
$wininet = Add-Type -memberDefinition ${source} -passthru -name InternetSettings
${wininet}::InternetSetOption([IntPtr]::Zero, 95, [IntPtr]::Zero, 0)|out-null
${wininet}::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0)|out-null

exit 0
