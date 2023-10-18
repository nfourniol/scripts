
# Filter Organisational Unit Messagerie (for instance, must be adapted) :
$OUpath = 'OU=Messagerie,DC=YOURCOMPANY,DC=com'
$arrayExpiryUser=(Get-ADUser -SearchBase $OUpath -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "UserPrincipalName", "msDS-UserPasswordExpiryTimeComputed" |
Select-Object -Property "Displayname","UserPrincipalName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Sort-Object -Property Displayname)


for ($i=0; $i -lt $arrayExpiryUser.Length; $i++) {
    # Commands to execute for each item in the array
    if (($arrayExpiryUser[$i]."ExpiryDate") -lt ((Get-Date).AddDays(7)) -And ((Get-Date) -lt ($arrayExpiryUser[$i]."ExpiryDate"))) {
        echo "$($arrayExpiryUser[$i]."DisplayName") a son password qui expire bientôt : $($arrayExpiryUser[$i]."ExpiryDate")"

        $EmojiIconCode = [System.Convert]::toInt32("1F600",16)
        $EmojiIconSmile = [System.Char]::ConvertFromUtf32($EmojiIconCode)

        $EmojiIconCode = [System.Convert]::toInt32("01F609",16)
        $EmojiIconWink = [System.Char]::ConvertFromUtf32($EmojiIconCode)

        $mailTo = "{0} <{1}>" -f $arrayExpiryUser[$i]."DisplayName",$arrayExpiryUser[$i]."UserPrincipalName"
        $subject = "Votre mot de passe Windows expire le {0}" -f $arrayExpiryUser[$i]."ExpiryDate"
        $body=@"
Your Windows session password will expire soon.<br/>
Please change it when you come to OURCOMPANY.<br/><br/>
You will not be able to change it from your VPN access (i.e. remotely). $($EmojiIconWink)<br/>

As a reminder, your password must comply with the following strategy:<br>
    <ul>
        <li>12 characters minimum</li>
        <li>at least 3 different types of characters among the following types: upper case, lower case, number, special characters</li>
    </li>
    $($EmojiIconSmile)
"@
        echo $mailTo
        Send-MailMessage -From 'IT OURCOMPANY <it@yourdomain.com>' -To "$($mailTo)" -Subject "$($subject)" -Body "$($body)" -BodyAsHtml -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'smtp.yourcompany.com' -Encoding 'utf32'
    
    }
}
