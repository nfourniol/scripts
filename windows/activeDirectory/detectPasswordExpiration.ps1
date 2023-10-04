
# Filter Organisational Unit Messagerie (for instance, must be adapted) :
$OUpath = 'OU=Messagerie,DC=yourdomain,DC=com'
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
Le mot de passe de votre session Windows expire le $($arrayExpiryUser[$i]."ExpiryDate").<br/>
Veuillez le changer lors de votre présence à NOVRH.<br/><br/>
Vous ne pourrez pas le changer depuis votre accès VPN (c'est à dire en remote) $($EmojiIconWink)<br/>

Pour rappel, votre mot de passe doit respecter la stratégie suivante :<br>
    <ul>
        <li>12 caractères minimum</li>
        <li>au moins 3 types de caractères différents parmi les types suivants : majuscule, minuscule, chiffre, caractères spéciaux</li>
    </li>
    $($EmojiIconSmile)
"@
        echo $mailTo
        Send-MailMessage -From 'IT NOVRH <it@novrh.com>' -To "$($mailTo)" -Subject "$($subject)" -Body "$($body)" -BodyAsHtml -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'report.novrh.com' -Encoding 'utf32'
    
    }
}
