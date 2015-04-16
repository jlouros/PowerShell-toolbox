#template 
$TemplateAdr = @'
#CONTACT
   ID=11
   NAME={Name*:Justynka}
   CREATED=1195505237
   MAIL={Mail:JUSTYNA66@gmail.com}
   ICON=Contact0
 
#CONTACT
   ID=20
   NAME={Name*:Poczta Grupowa}
   URL=
   CREATED=1347221208
   DESCRIPTION=
   ACTIVE=YES
   MAIL={Mail:xyz.abc.grupa.foo@gmail.com}
   PHONE=
   FAX=
   POSTALADDRESS=
   PICTUREURL=
   ICON=Contact0
 
'@

#read 'contacts.txt' contents
$contacts = Get-Content .\contacts.adr

#parse contacts using the specified template
$contacts | ConvertFrom-String -TemplateContent $TemplateAdr | Format-Table -AutoSize Name, Mail


#read more about it at: http://www.powershellmagazine.com/2014/09/09/using-the-convertfrom-string-cmdlet-to-parse-structured-text/