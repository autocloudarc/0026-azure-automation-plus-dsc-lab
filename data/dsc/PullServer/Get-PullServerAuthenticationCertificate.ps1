$pullServerCertRequest = @{
    Template = 'PullServerAuth'
    DnsName = '<>'
    SubjectName = '<>'
    Url = 'ldap:'
    CertStoreLocation = 'Cert:\LocalMachine\My'
} # end hashtable

Get-Certificate @pullServerCertRequest