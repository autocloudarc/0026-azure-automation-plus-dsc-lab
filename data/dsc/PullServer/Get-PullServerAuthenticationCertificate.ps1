$pullServerCertRequest = @{
    Template = 'PullServerAuth'
<<<<<<< HEAD
    DnsName = 'cltdev1001.dev.adatum.com'
    SubjectName = 'CN=cltdev1001.dev.adatum.com'
=======
    DnsName = '<>'
    SubjectName = '<>'
>>>>>>> master
    Url = 'ldap:'
    CertStoreLocation = 'Cert:\LocalMachine\My'
} # end hashtable

Get-Certificate @pullServerCertRequest