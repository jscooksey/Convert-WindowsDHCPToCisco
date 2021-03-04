function Convert-Lease {
    param( [string]$leaseDuration)

    $textReformat = $leaseDuration -replace ",","."
    $seconds = ([TimeSpan]::Parse($textReformat)).TotalSeconds
    $days = [int]($seconds / 86400)
    $hours = [int]($seconds / 3600) % 24
    $minutes = [int]($seconds / 60) % 60
    $result = "lease " + [string]$days + " " + [string]$hours + " " + [string]$minutes
    return  $result
}

Convert-Lease -leaseDuration "8.03:14:12"