function Validate-Script
{
    param(
        [ValidateScript({$_ -gt (get-date)})][datetime]$eventDate
    ) #end param
    $eventDate
} #end function

$event = Get-Date
Validate-Script -eventDate $event.AddDays(1)