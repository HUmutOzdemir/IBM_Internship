[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
Add-Type -AssemblyName System.Windows.Forms

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'LogOff Script'
$main_form.AutoSize = $true
$main_form.MaximizeBox = $false
$main_form.FormBorderStyle = 'Fixed3D'

$ip_label = New-Object System.Windows.Forms.Label
$ip_label.Text = "IP Adress : "
$ip_label.AutoSize = $true
$ip_label.Location = New-Object System.Drawing.Point(10,10)
$main_form.Controls.Add($ip_label)

$ip_textbox = New-Object System.Windows.Forms.TextBox
$ip_textbox.AutoSize = $true
$ip_textbox.Enabled = $false
$ip_textbox.Location = New-Object System.Drawing.Point(90,10)
$ip_textbox.Add_TextChanged({
    $this.Text = $this.Text -replace "[^1-9^.]"
    if($this.Text.Length -gt 0){
            $this.Focus()
            $this.SelectionStart = $this.Text.Length
        }
})
$main_form.Controls.Add($ip_textbox)

$p_label = New-Object System.Windows.Forms.Label
$p_label.Text = "Admin Password : "
$p_label.AutoSize = $true
$p_label.Location = New-Object System.Drawing.Point(200,10)
$main_form.Controls.Add($p_label)

$p_textbox = New-Object System.Windows.Forms.MaskedTextBox
$p_textbox.PasswordChar = "*"
$p_textbox.AutoSize = $true
$p_textbox.Enabled = $false
$p_textbox.Location = New-Object System.Drawing.Point(325,10)
$main_form.Controls.Add($p_textbox)


$IsRemote = New-Object System.Windows.Forms.Checkbox 
$IsRemote.Location = New-Object System.Drawing.Point(435,10) 
$IsRemote.AutoSize = $true
$IsRemote.Text = "Active"
$IsRemote.add_CheckedChanged({
    if($IsRemote.Checked){
        $ip_textbox.Enabled = $true
        $p_textbox.Enabled = $true
    }else{
        $ip_textbox.Enabled = $flase
        $p_textbox.Enabled = $false
    }
})
$main_form.Controls.Add($IsRemote)

$userlist = New-Object System.Windows.Forms.ListView
$userlist.Location = New-Object System.Drawing.Point(10,40)
$userlist.Size = New-Object System.Drawing.Size(490,160)
$userlist.View = "Details"
$userlist.Scrollable=$true
$userlist.FullRowSelect=$true
$ColCheckBox=New-Object System.Windows.Forms.ColumnHeader
$ColCheckBox.Text="Username"
$ColCheckBox.Width=121.5
$ColCheckBox.TextAlign=[System.Windows.Forms.HorizontalAlignment]::Left
$userlist.Columns.Add($ColCheckBox)
$ColCheckBox2=New-Object System.Windows.Forms.ColumnHeader
$ColCheckBox2.Text="ID"
$ColCheckBox2.Width=121.5
$ColCheckBox2.TextAlign=[System.Windows.Forms.HorizontalAlignment]::Left
$userlist.Columns.Add($ColCheckBox2)
$ColCheckBox3=New-Object System.Windows.Forms.ColumnHeader
$ColCheckBox3.Text="State"
$ColCheckBox3.Width=121.5
$ColCheckBox3.TextAlign=[System.Windows.Forms.HorizontalAlignment]::Left
$userlist.Columns.Add($ColCheckBox3)
$main_form.Controls.Add($userlist)
$ColCheckBox4=New-Object System.Windows.Forms.ColumnHeader
$ColCheckBox4.Text="Idle Time"
$ColCheckBox4.Width=121.5
$ColCheckBox4.TextAlign=[System.Windows.Forms.HorizontalAlignment]::Left
$userlist.Columns.Add($ColCheckBox4)
$main_form.Controls.Add($userlist)


$connect_button = New-Object System.Windows.Forms.Button
$connect_button.Location = New-Object System.Drawing.Point(10,210)
$connect_button.AutoSize = $true
$connect_button.Text = "Show Users"
$connect_button.add_Click({
    $temp = $true
    if($IsRemote.Checked){
        if($ip_textbox.Text -notmatch "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"){
            [System.Windows.Forms.MessageBox]::Show("This is not aproper IP adress.")
            $ip_textbox.Text = ""
            $p_textbox.Text = ""
            return
        }
        $user = New-Object Management.Automation.PSCredential(([string](gwmi Win32_NTDomain).DomainName + '\Administrator').Trim(),(ConvertTo-SecureString -String $p_textbox.Text -AsPlainText -Force))
        $disc_user_list =  invoke-command -ComputerName $ip_textbox.Text -Credential $user -ScriptBlock{quser}
    }else{
        $disc_user_list = quser   
    }
    $userlist.Items.Clear()
    forEach($line in $disc_user_list){
        if($temp){
            $temp = $false
            continue
        }
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
        $item = New-Object System.Windows.Forms.ListViewItem($username)
        $item.SubItems.Add($ID)
        $item.SubItems.Add($state)
        $item.SubItems.Add($IdleTime)
        $userlist.Items.Add($item)
   }
   [System.Windows.Forms.MessageBox]::Show("Completed!")
})
$main_form.Controls.Add($connect_button)


$LogOff_Button = New-Object System.Windows.Forms.Button
$LogOff_Button.Location = New-Object System.Drawing.Point(110,210)
$LogOff_Button.AutoSize = $true
$LogOff_Button.Text = "LogOff Selected User"
$LogOff_Button.add_Click({
    if($IsRemote.Checked){
        if($ip_textbox.Text -notmatch "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"){
            [System.Windows.Forms.MessageBox]::Show("This is not aproper IP adress.")
            $ip_textbox.Text = ""
            $p_textbox.Text = ""
            return
        }
        $user = New-Object Management.Automation.PSCredential(([string](gwmi Win32_NTDomain).DomainName + '\Administrator').Trim(),(ConvertTo-SecureString -String $p_textbox.Text -AsPlainText -Force))
        foreach($item in $userlist.SelectedItems){
            if($item.SubItems[2].Text -eq "Active"){
                $UserResponse= [System.Windows.Forms.MessageBox]::Show("Do you want to log off an active user?" , "Warning" , 4)
                if ($UserResponse -eq "YES"){
                    invoke-command -ComputerName $ip_textbox.Text -Credential $user -ScriptBlock{logoff $args[0]} -ArgumentList $item.SubItems[1].Text
                    $item.Remove()
                }
            }else{
               invoke-command -ComputerName $ip_textbox.Text -Credential $user -ScriptBlock{logoff $args[0]} -ArgumentList $item.SubItems[1].Text
               $item.Remove()
            }
        }
    }else{
        foreach($item in $userlist.SelectedItems){
            if($item.SubItems[2].Text.Equals("Active")){
                $UserResponse= [System.Windows.Forms.MessageBox]::Show("Do you want to log off an active user?" , "Warning" , 4)
                if ($UserResponse -eq "YES"){
                    logoff $item.SubItems[1].Text
                    $item.Remove()
                }
            }else{
                logoff $item.SubItems[1].Text
                $item.Remove()
            }
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Finished!")
})
$main_form.Controls.Add($LogOff_Button)

$LogOffAll_Button = New-Object System.Windows.Forms.Button
$LogOffAll_Button.Location = New-Object System.Drawing.Point(265,210)
$LogOffAll_Button.AutoSize = $true
$LogOffAll_Button.Text = "LogOff DU with :"
$LogOffAll_Button.add_Click({
    if($IsRemote.Checked -and $ip_textbox.Text -notmatch "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"){
        [System.Windows.Forms.MessageBox]::Show("This is not aproper IP adress.")
        $ip_textbox.Text = ""
        $p_textbox.Text = ""
        return
    }
    foreach($item in $userlist.Items){
       if($item.SubItems[2].Text -eq "Disc"){
            #Converts the idle time to minutes
            $IdleTime = $item.SubItems[3].Text
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

            if($IdleTimeInteger -ge [int]$threshold_textbox.Text){
                if($IsRemote.Checked){
                    $user = New-Object Management.Automation.PSCredential(([string](gwmi Win32_NTDomain).DomainName + '\Administrator').Trim(),(ConvertTo-SecureString -String $p_textbox.Text -AsPlainText -Force))
                    invoke-command -ComputerName $ip_textbox.Text -Credential $user -ScriptBlock{logoff $args[0]} -ArgumentList $item.SubItems[1].Text
                }else{
                    logoff $item.SubItems[1].Text
                }
                $item.Remove()
            }
       }
    }
    [System.Windows.Forms.MessageBox]::Show("Finished!")
 })
$main_form.Controls.Add($LogOffAll_Button)

$threshold_textbox = New-Object System.Windows.Forms.TextBox
$threshold_textbox.Text = "in Minutes"
$threshold_textbox.AutoSize = $true
$threshold_textbox.Enabled = $true
$threshold_textbox.Location = New-Object System.Drawing.Point(390,215)
$threshold_textbox.add_TextChanged({
    $this.Text = $this.Text -replace '\D'
        if($this.Text.Length -gt 0){
            $this.Focus()
            $this.SelectionStart = $this.Text.Length
        }
})
$main_form.Controls.Add($threshold_textbox)



$main_form.ShowDialog()
