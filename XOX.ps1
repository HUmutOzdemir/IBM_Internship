#2-D array representation of grid
$global:grid = (("1","2","3"),("4","5","6"),("7","8","9"));
#Turn of game
$global:turn = "X";

#Controls the gird wheather game finished or not.
function winning{
For($i=0;$i -lt 3;$i++){
    if($global:grid[$i][0].Equals($global:grid[$i][1]) -AND $global:grid[$i][0].Equals($global:grid[$i][2])){
        return $true;
        }
}
For($i=0;$i -lt 3;$i++){
    if($global:grid[0][$i].Equals($global:grid[1][$i]) -AND $global:grid[0][$i].Equals($global:grid[2][$i])){
        return $true;
        }
}
return ($global:grid[0][0].Equals($global:grid[1][1]) -AND $global:grid[0][0].Equals($global:grid[2][2])) -OR ($global:grid[0][2].Equals($global:grid[1][1]) -AND $global:grid[1][1].Equals($global:grid[2][0]));
}

Add-Type -assembly System.Windows.Forms;

#Creates the GUI Window
$main_form = New-Object System.Windows.Forms.Form;

$main_form.Text = 'X0X';
$main_form.Width=350;
$main_form.Height=350;

$main_form.AutoSize=$true;

#Creates a label for presenting turn and winner.
$Label = New-Object System.Windows.Forms.Label;
$Label.Text = $turn + "'s Turn!";
$Label.Location  = New-Object System.Drawing.Point(115,10);
$Label.AutoSize = $true;

$main_form.Controls.Add($Label);

#For Button 0-8 all buttons are part of the 3x3 grid
#For all button clicks it changes the buttons text and controls the winning condition
#And changes the turn label if game continues
$Button0 = New-Object System.Windows.Forms.Button;
$Button0.Location = New-Object System.Drawing.Size(50,40);
$Button0.Size = New-Object System.Drawing.Size(80,80);
$Button0.Text = " ";
$Button0.Add_Click(

{
$Button0.Enabled=$false;
$Button0.Text = $global:turn;
If ($turn.Equals("X")) {
    $global:grid[0][0] = "X";
    $global:turn = "0";
 }Else {
  $global:grid[0][0] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}


}

)
$main_form.Controls.Add($Button0);


$Button1 = New-Object System.Windows.Forms.Button;
$Button1.Location = New-Object System.Drawing.Size(130,40);
$Button1.Size = New-Object System.Drawing.Size(80,80);
$Button1.Text = " ";
$Button1.Add_Click(

{

$Button1.Text = $global:turn;
$Button1.Enabled=$false;

If ($turn.Equals("X")) {
    $global:grid[0][1] = "X";
    $global:turn = "0";
  }  Else {
  $global:grid[0][1] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}

}

)
$main_form.Controls.Add($Button1);

$Button2 = New-Object System.Windows.Forms.Button;
$Button2.Location = New-Object System.Drawing.Size(210,40);
$Button2.Size = New-Object System.Drawing.Size(80,80);
$Button2.Text = " ";
$Button2.Add_Click(

{

$Button2.Text = $global:turn;
$Button2.Enabled=$false;

If ($turn.Equals("X")) {
    $global:grid[0][2] = "X";
    $global:turn = "0";
  }  Else {
  $global:grid[0][2] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}

}

)
$main_form.Controls.Add($Button2);

$Button3 = New-Object System.Windows.Forms.Button;
$Button3.Location = New-Object System.Drawing.Size(50,120);
$Button3.Size = New-Object System.Drawing.Size(80,80);
$Button3.Text = " ";
$Button3.Add_Click(

{

$Button3.Text = $global:turn;
$Button3.Enabled=$false;

If ($turn.Equals("X")) {
    $global:grid[1][0] = "X";
    $global:turn = "0";
  }  Else {
  $global:grid[1][0] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}

}

)
$main_form.Controls.Add($Button3);

$Button4 = New-Object System.Windows.Forms.Button;
$Button4.Location = New-Object System.Drawing.Size(130,120);
$Button4.Size = New-Object System.Drawing.Size(80,80);
$Button4.Text = " ";
$Button4.Add_Click(

{

$Button4.Text = $global:turn;
$Button4.Enabled=$false;

If ($turn.Equals("X")) {
    $global:grid[1][1] = "X";
    $global:turn = "0";
  }  Else {
  $global:grid[1][1] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}

}

)
$main_form.Controls.Add($Button4);

$Button5 = New-Object System.Windows.Forms.Button;
$Button5.Location = New-Object System.Drawing.Size(210,120);
$Button5.Size = New-Object System.Drawing.Size(80,80);
$Button5.Text = " ";
$Button5.Add_Click(

{

$Button5.Text = $global:turn;
$Button5.Enabled=$false;

If ($turn.Equals("X")) {
    $global:grid[1][2] = "X";
    $global:turn = "0";
  }  Else {
  $global:grid[1][2] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}

}

)
$main_form.Controls.Add($Button5);

$Button6 = New-Object System.Windows.Forms.Button;
$Button6.Location = New-Object System.Drawing.Size(50,200);
$Button6.Size = New-Object System.Drawing.Size(80,80);
$Button6.Text = " ";
$Button6.Add_Click(

{

$Button6.Text = $global:turn;
$Button6.Enabled=$false;

If ($turn.Equals("X")) {
    $global:grid[2][0] = "X";
    $global:turn = "0";
  }  Else {   
  $global:grid[2][0] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}

}

)
$main_form.Controls.Add($Button6);

$Button7 = New-Object System.Windows.Forms.Button;
$Button7.Location = New-Object System.Drawing.Size(130,200);
$Button7.Size = New-Object System.Drawing.Size(80,80);
$Button7.Text = " ";
$Button7.Add_Click(

{

$Button7.Text = $global:turn;
$Button7.Enabled=$false;

If ($turn.Equals("X")) {
    $global:grid[2][1] = "X";
    $global:turn = "0";
  }  Else {
  $global:grid[2][1] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}

}

)
$main_form.Controls.Add($Button7);

$Button8 = New-Object System.Windows.Forms.Button;
$Button8.Location = New-Object System.Drawing.Size(210,200);
$Button8.Size = New-Object System.Drawing.Size(80,80);
$Button8.Text = " ";
$Button8.Add_Click(

{

$Button8.Text = $global:turn;
$Button8.Enabled=$false;

If ($turn.Equals("X")) {
    $global:grid[2][2] = "X";
    $global:turn = "0";
  }  Else {
  $global:grid[2][2] = "0";
  $global:turn = "X";
} 
If(winning){
    $Label.Text = "You Win!!";
}Else{
    $Label.Text = $global:turn + "'s Turn!";
}

}

)
$main_form.Controls.Add($Button8);



$main_form.ShowDialog();

