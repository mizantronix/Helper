#BEGIN:VCARD
#VERSION:3.0
#N:LastName;FirstName;;;
#FN:FirstName LastName
#ORG:OrganizationName;OfficeName
#BDAY;VALUE=date:yyyy-MM-dd
#TITLE:Title
#TEL;TYPE=CELL;TYPE=pref;TYPE=VOICE:+7 (999) 999-99-99
#email;type=work;type=pref;type=internet:email@mail.com
#CATEGORIES:myContacts
#END:VCARD

$org = "YourOrganizationName"

#FullName;Office;Role;Bday;Phone;email
$content = Get-Content .\1people.csv

$tmp = New-TemporaryFile
$res = @()

foreach($str in $content) {
	$parts = $str.Split(';')
	$res += 'BEGIN:VCARD'
	$res += 'VERSION:3.0'
	
	$names = $parts[0].Split(' ')
	$res += "N:$($names[0]);$($names[1]);;;"
	$res += "FN:$($names[1]) $($names[0])"
	
	$res += "ORG:$org;$($parts[1])"
	
	$dbDateParts = $parts[3].Split('.')
	$formatedDate = "$($dbDateParts[2])-$($dbDateParts[1])-$($dbDateParts[0])"
	$res += "BDAY;VALUE=date:$formatedDate"
	
	$res += "TITLE:$($parts[2])"
	
	$phoneParts = $parts[4].Split('-')
	$formatedPhone = "$($phoneParts[0]) ($($phoneParts[1])) $($phoneParts[2])-$($phoneParts[3])-$($phoneParts[4])"
	$res += "TEL;TYPE=CELL;TYPE=pref;TYPE=VOICE:$formatedPhone"
	
	$res += "email;type=work;type=pref;type=internet:$($parts[5])"
	
	
	$res += "CATEGORIES:myContacts"
	$res += "END:VCARD"
}

$res | Out-File -Append $tmp



