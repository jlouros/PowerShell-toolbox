<#
.SYNOPSIS
	Disable known weak cryptographic protocols
.NOTES    
	Instructs Schannel to disable known weak cryptographic algorithms, cipher suites, and SSL/TLS protocol versions that may be otherwise enabled for better interoperability.
    In .Net framework 4.5.2 and below, if strong cryptography is not set, SSL 3.0 or TLS 1.0 will be used by default.
    For .Net 4.6.1 strong cryptography is enabled by default, meaning that secure HTTP communications will use TLS 1.0, TLS 1.1 or TLS 1.2.
#>  


# set strong cryptography on 64 bit .Net Framework
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord


# set strong cryptography on 32 bit .Net Framework
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
