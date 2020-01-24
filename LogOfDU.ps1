param([Parameter(Mandatory=$True)][string]$Name,
      [Parameter(Mandatory=$True)][int]$MaxIdleTime)

#List all of the users
$disc_user_list = query user

forEach($line in $disc_user_list){

    $line = -split $line

    #Checks for is there a session name or not
    if($line.length -eq 7){
        $username = $line[0]
        $ID = $line[1]
        $state = $line[2]
        $IdleTime = $line[3]
    }else{
        $username = $line[0]
        $ID = $line[2]
        $state = $line[3]
        $IdleTime = $line[4]
    }
    #Converts the idle time to minutes
    $IdleTimeInteger = 0
    $tempArray = $IdleTime.Split("+")
    if($tempArray.length -eq 2){
        $IdleTimeInteger = $IdleTimeInteger + ([int]$tempArray[0])*1440
        $IdleTime = $tempArray[1]
    }
    $tempArray = $IdleTime.Split(":")
    if($tempArray.Length -eq 2){
        $IdleTimeInteger = $IdleTimeInteger + ([int]$tempArray[0])*60
        $IdleTime = $tempArray[1]
    }
    if($IdleTime -match "^\d*$"){
        $IdleTimeInteger = $IdleTimeInteger + [int]$IdleTime
    }
    if($state -eq "Disc"){
        if($username -match $Name){
            if($IdleTimeInteger -ge $MaxIdleTime){
                Write-Host $username kapatılacak.
                logoff $ID
            }
        }
    }
}

Write-Host Tamamlandı...