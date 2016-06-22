#Requires -RunAsAdministrator

###########
# Reference: http://stackoverflow.com/questions/19238520/how-to-configure-web-deploy-publishing-feature-on-iis-so-developer-can-publish#23140489
############


# 1st step: Manuall install webdeploy

# 2nd step: Run the following
Install-WindowsFeature Web-Server
Install-WindowsFeature Web-Mgmt-Service
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1
Net Stop WMSVC
Net Start WMSVC

netsh advfirewall firewall add rule name="Allow Web Management" dir=in action=allow service="WMSVC"