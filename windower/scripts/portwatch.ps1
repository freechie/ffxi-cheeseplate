# Logs ephemeral port usage per process so the one that exhausts the pool
# can be named. Windows System log Tcpip 4231/4266 ("all such ports being
# in use") fired during FFXI sessions on 10/9, 10/11, 10/12, 10/13 and 10/15.
# A full pool makes zoning fail (new UDP socket) and login fail (POL-0011,
# POL-1160) while other apps still look fine.
#
# Run:  powershell -ExecutionPolicy Bypass -File windower\scripts\portwatch.ps1
# Stop: close the window, or  Get-Process -Name powershell | Where-Object { $_.CommandLine -match 'portwatch' } | Stop-Process
# Log:  %LOCALAPPDATA%\ffxi-portwatch\portwatch.log  (one line per sample)
#       %LOCALAPPDATA%\ffxi-portwatch\detail-*.log   (full breakdown when the pool is above the alarm line)

param(
    [int]$IntervalSeconds = 20,
    [int]$AlarmPorts = 4000
)

$dir = Join-Path $env:LOCALAPPDATA 'ffxi-portwatch'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$log = Join-Path $dir 'portwatch.log'

function ProcName($pid_) {
    if ($pid_ -eq 0) { return 'TimeWait/none' }
    $p = Get-Process -Id $pid_ -ErrorAction SilentlyContinue
    if ($p) { return $p.ProcessName } else { return "pid$pid_" }
}

while ($true) {
    $now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $tcp = @(Get-NetTCPConnection -ErrorAction SilentlyContinue)
    $udp = @(Get-NetUDPEndpoint -ErrorAction SilentlyContinue)
    $timewait = @($tcp | Where-Object State -eq 'TimeWait').Count
    $ephemeralTcp = @($tcp | Where-Object { $_.LocalPort -ge 1024 -and $_.State -ne 'Listen' }).Count
    $ephemeralUdp = @($udp | Where-Object { $_.LocalPort -ge 1024 }).Count
    $pol = if (Get-Process -Name pol -ErrorAction SilentlyContinue) { 'pol' } else { '-' }

    $byProc = @{}
    foreach ($c in $tcp) { if ($c.State -ne 'Listen') { $byProc[$c.OwningProcess] = 1 + [int]$byProc[$c.OwningProcess] } }
    foreach ($u in $udp) { $byProc[$u.OwningProcess] = 1 + [int]$byProc[$u.OwningProcess] }
    $top = $byProc.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 3 |
        ForEach-Object { '{0}={1}' -f (ProcName $_.Key), $_.Value }

    $line = '{0} {1,-3} tcp={2,-5} timewait={3,-5} udp={4,-5} top: {5}' -f $now, $pol, $ephemeralTcp, $timewait, $ephemeralUdp, ($top -join ' ')
    Add-Content -Path $log -Value $line

    if (($ephemeralTcp + $ephemeralUdp) -ge $AlarmPorts) {
        $detail = Join-Path $dir ('detail-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
        $out = @("# $now  tcp=$ephemeralTcp timewait=$timewait udp=$ephemeralUdp", '', '## by process (tcp non-listen + udp)')
        $out += $byProc.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 15 |
            ForEach-Object { '{0,6}  {1}' -f $_.Value, (ProcName $_.Key) }
        $out += '', '## TCP by state'
        $out += $tcp | Group-Object State | Sort-Object Count -Descending | ForEach-Object { '{0,6}  {1}' -f $_.Count, $_.Name }
        $out += '', '## TCP remote endpoints (top 15)'
        $out += $tcp | Where-Object State -ne 'Listen' | Group-Object RemoteAddress, RemotePort | Sort-Object Count -Descending |
            Select-Object -First 15 | ForEach-Object { '{0,6}  {1}' -f $_.Count, $_.Name }
        $out += '', '## UDP by process'
        $out += $udp | Group-Object OwningProcess | Sort-Object Count -Descending | Select-Object -First 10 |
            ForEach-Object { '{0,6}  {1}' -f $_.Count, (ProcName ([int]$_.Name)) }
        Set-Content -Path $detail -Value $out
    }

    Start-Sleep -Seconds $IntervalSeconds
}
