###############################################################################

# Create an error
Get-InvalidFunction

# Find the exception
$Error[0] | Select-Object Exception | ft -Wrap

<#
Exception                                                                                         
---------                                                                                         
System.Management.Automation.CommandNotFoundException: The term 'Get-InvalidFunction' is not      
recognized as the name of a cmdlet, function, script file, or operable program. Check the         
spelling of the name, or if a path was included, verify that the path is correct and try again.   
   at System.Management.Automation.CommandDiscovery.LookupCommandInfo(String commandName,         
CommandTypes commandTypes, SearchResolutionOptions searchResolutionOptions, CommandOrigin         
#>

###############################################################################

# Create a trap (or catch)
Trap [System.Management.Automation.CommandNotFoundException] {
    "Where did you find that command?"
}

# Create a trapped error
Get-InvalidFunction

###############################################################################

# Create a trap (or catch)
Trap [System.Management.Automation.CommandNotFoundException] {
    "Where did you find that command?"
}

# Catch all
Trap {
    "I don't know what you are trying to do."
}

# Create a trapped error
Get-Service asdf -ErrorAction Stop
