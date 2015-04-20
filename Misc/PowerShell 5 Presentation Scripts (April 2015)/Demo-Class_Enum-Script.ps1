#Requires -Version 5.0


# declare a enum
Enum PrtgMode { 
    On 
    Off
}

# define a class
Class WebsiteMonitor
{
    #Properties
    [Boolean]$prtg
    [int]$TIMEOUT = 3000
    [string]$TargetNodeCompName

    #Constructor
    WebsiteMonitor([string]$target) {
        $this.prtg = $false
        $this.TargetNodeCompName = $target

        # disable SSL certificate checks (might be needed)
        #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    #Constructor
    WebsiteMonitor([string]$target, [PrtgMode] $setPrtg) {
        $this.prtg = $setPrtg -eq [PrtgMode]::On
        $this.TargetNodeCompName = $target

        # disable SSL certificate checks (might be needed)
        #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }
	
    #Methods
    [Void] AssertWebsiteIsAvailable ([String]$hostHeader, [String]$path) 
    {
        $uri = 'https://' + $this.TargetNodeCompName + $path
		
        try {

            if (!$this.prtg) {
                Write-Host "Verifying Website '$uri' is available. TargetNodeCompName=$($this.TargetNodeCompName) HostHeader=$hostHeader path=$path"            
            }

            $req = [system.Net.HttpWebRequest]::Create($uri)
            if (!([string]::IsNullOrEmpty($hostheader))) {
                $req.Host = $hostHeader
            }
            $req.Timeout = $this.TIMEOUT
            $req.UserAgent = 'PRTG/Go Health Check'
            $res = $req.getresponse()
            $status = $res.statuscode
            $content_length = $res.contentlength
            $res.close();

            If (!($status -eq 200 -and $content_length -gt 0)) {
                if ($this.prtg) {
                    Write-Host -nonewline '2:'
                }
                Write-Host "Verification of '$uri' failed. HTTP Status is '$status' and Content-Length is '$content_length'"
            }
        } catch [Exception] {
            if ($this.prtg) {
                Write-Host -nonewline '2:'
            }
            Write-Host "Verification of '$uri' failed. More info: " $_.Exception.Message
        }
    }
}







# create a new instance of 'WebsiteMonitor'
$monitor = [WebsiteMonitor]::New('VirtualMachine-Name',[PrtgMode]::Off)


$sitesToVerify = @(
    ('ps1.localhost', '/MagensaDemo/ServiceRelay.asmx'),
    ('gwadmin.localhost', '/signin.aspx'),
    ('genius.localhost', '/v1/Login.aspx'),
    ('manage.localhost', '/MobileAccess/CredentialService.asmx'),
    ('transport.localhost', '/v4/TransportService.asmx')
)

# call 'AssertWebsiteIsAvailable' method for each entrie in '$sitesToVerify' array
foreach ($value in $sitesToVerify) {
    $monitor.AssertWebsiteIsAvailable($value[0],$value[1])
}
