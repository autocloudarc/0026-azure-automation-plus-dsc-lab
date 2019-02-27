$pullServerCertRequest = @{
    Template = 'PullServerAuth'
    DnsName = 'cltdev1001.dev.adatum.com'
    SubjectName = 'CN=cltdev1001.dev.adatum.com'
    Url = 'ldap:'
    CertStoreLocation = 'Cert:\LocalMachine\My'
} # end hashtable

Get-Certificate @pullServerCertRequest