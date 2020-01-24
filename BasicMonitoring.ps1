[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
Add-Type -AssemblyName System.Windows.Forms

$sync = [Hashtable]::Synchronized(@{})

$updater = {
    $update = [PowerShell]::Create().AddScript({
        $timer = 1000
        $sync.Exit_Button.Enabled = $true
        $sync.Button.Enabled = $false
        while($true){
            $CPU_usage = (Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average).Average
            $CPU_temp_kelvin = (Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi").CurrentTemperature / 10
            $os = Get-Ciminstance Win32_OperatingSystem
            $memory_usage = 100 -[math]::Round(($os.FreePhysicalMemory / $os.TotalVisibleMemorySize)*100,2)

            $sync.CPU_usage_label.Text = [string]($CPU_usage) + " %"
            if($CPU_usage -ge [int]$sync.thres_array[0].Text){
                Invoke-Command $sync.commands[$sync.comboboxes[0].SelectedText]
            }
            $sync.CPU_temp_label.Text = [string]($CPU_temp_kelvin - 273) + " Celcius"
            if(($CPU_temp_kelvin - 273) -ge [int]$sync.thres_array[1].Text){
                Invoke-Command $sync.commands[$sync.comboboxes[1].SelectedText]
            }
            $sync.Memory_l.Text = [string]($memory_usage) + " %"
            if($memory_usage -ge [int]$sync.thres_array[2].Text){
                Invoke-Command $sync.commands[$sync.comboboxes[2].SelectedText]
            }
            
            if($timer -eq 1000){
                $disks = Get-WmiObject -Class Win32_logicaldisk
                for($i = 0; $i -lt $disks.Count ; $i++){
                    $sync.labelArray[$i].Text = [string](100-[math]::Round(($disks[$i].FreeSpace/$disks[$i].Size)*100,2)) + " %"
                }
                $timer = 0
            }
            $timer = $timer + 1
            Start-Sleep -Seconds 0.01
            if($sync.Exit_loop){
               forEach($combo in $sync.comboboxes){
                $combo.SelectedIndex = 0
               }
               $timer = 0;
               $sync.Exit_loop = $false
               $sync.Exit_Button.Enabled = $false
               $sync.Button.Enabled = $true 
               break
            }
        }
    })
    $runspace = [RunspaceFactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("sync", $sync)
    
    $update.Runspace = $runspace
    $update.BeginInvoke()
}

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Monitoring Script'
$main_form.MaximizeBox = $false
$main_form.FormBorderStyle = 'Fixed3D'
$main_form.AutoSize = $true
$main_form.Height = 240

$CPU_label = New-Object System.Windows.Forms.Label
$CPU_label.Text = "CPU Usage Percentage : "
$CPU_label.AutoSize = $true
$CPU_label.Location = New-Object System.Drawing.Point(10,10)
$main_form.Controls.Add($CPU_label)

$CPU_usage_label = New-Object System.Windows.Forms.TextBox
$CPU_usage_label.ReadOnly = $true
$CPU_usage_label.AutoSize = $true
$CPU_usage_label.Location = New-Object System.Drawing.Point(180,10)
$main_form.Controls.Add($CPU_usage_label)

$CPU_temp = New-Object System.Windows.Forms.Label
$CPU_temp.Text = "CPU Temperature : "
$CPU_temp.AutoSize = $true
$CPU_temp.Location = New-Object System.Drawing.Point(10,40)
$main_form.Controls.Add($CPU_temp)

$CPU_temp_label = New-Object System.Windows.Forms.TextBox
$CPU_temp_label.ReadOnly = $true
$CPU_temp_label.AutoSize = $true
$CPU_temp_label.Location = New-Object System.Drawing.Point(180,40)
$main_form.Controls.Add($CPU_temp_label)

$Memory = New-Object System.Windows.Forms.Label
$Memory.Text = "Memory Usage : "
$Memory.AutoSize = $true
$Memory.Location = New-Object System.Drawing.Point(10,70)
$main_form.Controls.Add($Memory)

$Memory_l = New-Object System.Windows.Forms.TextBox
$Memory_l.ReadOnly = $true
$Memory_l.AutoSize = $true
$Memory_l.Location = New-Object System.Drawing.Point(180,70)
$main_form.Controls.Add($Memory_l)

$thres_array = [System.Collections.ArrayList]@()
$comboboxes = [System.Collections.ArrayList]@()

For($i=0; $i -lt 3; $i++){
    $temp = New-Object System.Windows.Forms.Label
    $temp.Text = "Threshold : "
    $temp.AutoSize = $true
    $temp.Location = New-Object System.Drawing.Point(285,(10 + 30 * $i))
    $main_form.Controls.Add($temp)

    $temp_text = New-Object System.Windows.Forms.TextBox
    $temp_text.AutoSize = $true
    $temp_text.MaxLength = 3
    $temp_text.Text = 0
    $temp_text.Size = New-Object System.Drawing.Size(25,0)
    $temp_text.Location = New-Object System.Drawing.Point(370,(10 + 30 * $i))
    $temp_text.Add_TextChanged({
        $this.Text = $this.Text -replace '\D'
        if($this.Text.Length -gt 0){
            $this.Focus()
            $this.SelectionStart = $this.Text.Length
        }
    })
    $thres_array.Add($temp_text)
    $main_form.Controls.Add($temp_text)

    $combo = New-Object System.Windows.Forms.ComboBox
    $combo.AutoSize = $true
    $combo.Location = New-Object System.Drawing.Point(400,(10 + 30 * $i))
    $combo.Items.Add("Do Nothing")
    $combo.Items.Add("Restart")
    $combo.Items.Add("Shut Down")
    $combo.Items.Add("Warning")
    $combo.SelectedIndex = 0
    
    $comboboxes.Add($combo)
    $main_form.Controls.Add($combo)

    $temp = New-Object System.Windows.Forms.Label
    $temp.Text = "If it exist the threshold."
    $temp.AutoSize = $true
    $temp.Location = New-Object System.Drawing.Point(525,(10 + 30 * $i))
    $main_form.Controls.Add($temp)
}

$labelArray = [System.Collections.ArrayList]@()

$counter = 0
$disks = Get-WmiObject -Class Win32_logicaldisk
ForEach($disk in $disks){
    $Temp = New-Object System.Windows.Forms.Label
    $Temp.Text = "Usage Percentage "+ $disk.DeviceId
    $Temp.AutoSize = $true
    $Temp.Location = New-Object System.Drawing.Point(10,(100+$counter*30))
    $main_form.Controls.Add($Temp)

    $Temp_l = New-Object System.Windows.Forms.TextBox
    $Temp_l.ReadOnly = $true
    $Temp_l.AutoSize = $true
    $Temp_l.Location = New-Object System.Drawing.Point(180,(100+$counter*30))
    $main_form.Controls.Add($Temp_l)
    $labelArray.Add($Temp_l)
    $counter = $counter + 1
}

$Exit_Button =  New-Object System.Windows.Forms.Button
$Exit_Button.Location = New-Object System.Drawing.Point(10,(100+$counter*30))
$Exit_Button.AutoSize = $true
$Exit_Button.Enabled = $false
$Exit_Button.Text = "End"
$Exit_Button.Add_Click({
    $sync.Exit_loop = $true
})

$main_form.Controls.Add($Exit_Button)
$Exit_loop = $false

$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Point(180,(100+$counter*30))
$Button.AutoSize = $true
$Button.Text = "Start"
$Button.Add_Click($updater)
$main_form.Controls.Add($Button)

$commands = @{"Restart" = {[System.Windows.MessageBox]::Show('Computer will restart after 5 seconds.');Start-Sleep -Seconds 5;Restart-Computer}; "Shut Down" = {[System.Windows.MessageBox]::Show('Computer will shut down after 5 seconds');Start-Sleep -Seconds 5;Stop-Computer};"Warning" = {[System.Windows.MessageBox]::Show('Warning')}}

$sync.Button = $Button
$sync.CPU_usage_label = $CPU_usage_label
$sync.CPU_temp_label = $CPU_temp_label
$sync.Memory_l = $Memory_l
$sync.main_form = $main_form
$sync.Exit_loop = $false
$sync.Exit_Button = $Exit_Button
$sync.comboboxes = $comboboxes
$sync.thres_array = $thres_array
$sync.commands = $commands
$sync.labelArray = $labelArray

$main_form.ShowDialog()