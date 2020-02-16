# Following Script will list all the profiles and are ordered in the order the PowerShell will run when you invoke it.
# After running each command you will see the path for that particular profile

#All Users & All Hosts
$profile.AllUsersAllHosts

#All Users & Current Host
$profile.AllUsersCurrentHost

#Current User & All Hosts
$profile.CurrentUserAllHosts

#Current User & Current Host
$profile.CurrentUserCurrentHost