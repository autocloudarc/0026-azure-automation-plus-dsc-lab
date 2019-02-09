#region Header
<#
    Windows PowwerShell v4.0 for the IT Professional - Part 2
    Module 5: Regular Expressions
    Student Lab Manual

    Conditions and Terms of Use 
    Microsoft Confidential - For Internal Use Only 
 
    This training package is proprietary and confidential, and is intended only for uses described in the training materials. Content and software is provided to you under a Non-Disclosure Agreement and cannot be distributed. Copying or disclosing all or any portion of the content and/or software included in such packages is strictly prohibited. 
    The contents of this package are for informational and training purposes only and are provided "as is" without warranty of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement. 
    Training package content, including URLs and other Internet Web site references, is subject to change without notice. Because Microsoft must respond to changing market conditions, the content should not be interpreted to be a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of publication. Unless otherwise noted, the companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place, or event is intended or should be inferred.  
 
    © 2014 Microsoft Corporation. All rights reserved.

    Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property. 
    Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.  
    For more information, see Use of Microsoft Copyrighted Content at http://www.microsoft.com/about/legal/permissions/ 
    Microsoft®, Internet Explorer®, and Windows® are either registered trademarks or trademarks of Microsoft Corporation in the United States and/or other countries. Other Microsoft products mentioned herein may be either registered trademarks or trademarks of Microsoft Corporation in the United States and/or other countries. All other trademarks are property of their respective owners. 
#>
#endregion header

#region contents
<#
    LAB 5: REGULAR EXPRESSIONS (REGEX)
        Exercise 5.1: REGULAR EXPRESSIONS (REGEX)
            Task 5.1.1: Create a simple Regex email address pattern
            Task 5.1.4: A RegEx pattern to rename multiple files
#>
#endregion contents

#region Introduction
<#
    Introduction 
 
    A regular expression is a pattern that the regular expression engine attempts to match in input text. A pattern consists of one or more character literals, operators, or constructs. 
 
    Objectives  

    After completing this lab, you will be able to: 
     Understand how to use   Regular Expressions 
 
    Prerequisites Start all VMs provided for the workshop labs. Logon to WIN8-MS as Contoso\Administrator, using the password PowerShell4. 
 
    Estimated time to complete this lab  60 minutes

    NOTE: These exercises use many Windows PowerShell Cmdlets. You can type these commands into the Windows PowerShell Integrated Scripting Environment (ISE).  
    Each lab has its own files. For example, the lab exercises for module 7 have a folder at C:\PShell\Labs\Lab_7 on WIN8-WS.  
    We also recommend that you connect to the virtual machines for these labs through Remote Desktop rather than connecting through the Hyper-V console. 
    When you connect with Remote Desktop, you can copy and paste from one virtual machine to another.

    Scenario
#>
#endregion Introduction

#region 5.1: Regular Expressions (RegEx)
<#
    Introduction 

    Regular expressions provide a powerful, flexible, and efficient method for processing text. The extensive pattern-matching notation of regular expressions enables you to quickly parse large amounts of text to find specific character patterns; to validate text to ensure that it matches a predefined pattern (such as an e-mail address); to extract, edit, replace, or delete text substrings; and to add the extracted strings to a collection in order to generate a report.  
    For many applications that deal with strings or that parse large blocks of text, regular expressions are an indispensable tool. 
 
    Objectives  
    
    After completing this exercise, you will be able to:  Create a regular expression pattern  Understand basic regular expression operators. 
    Scenario  
    You are an administrator of Windows systems within Contoso.com and wish to find complex patterns within strings.  
#>
#region 5.1.1: Create a Simple Regex address pattern
<#

#>
#endregion 5.1.1
#region 5.1.2: A RegEx pattern to find Hotfix information
<#
We shall use a very simple pattern to find any email addresses in a string.  The formal RFC822 address specification is rigorous and far beyond our scope.  
You will build a reasonable pattern that is mostly compliant with the standard. 
 
There are multiple ways to create patterns to achieve your objective. We shall use one very simple form in this example. 
You may well create a better solution on your own. 
 
You wish to search within a string for likely email addresses, of the general form "user@contoso.com". This might be text in a file, data in a form, or something similar. 
NOTE: To learn about RegEx operators in detail go to http://www.bing.com and search MSDN “Regular Expression Language - Quick Reference”. 
#>
<#
1. A regular-expression pattern in the form of [set] might be "[A-Z0-9]". 
   This is how to say “the set of usual alphabet characters and the set of numbers”. It refers to just one single character. 
   Select the follwing and press F8 to execute the selection.
   Initialize $matches system variable
#>

$matches = ''
# Define pattern
$pat = "[A-Z0-9]"
# Test pattern for a match
"A" -match $pat 
<#
2. Now let's modify the previous pattern of "[A-Z0-9]" to inlcude the following special characters: "_",".", "%", "+", and "-".
   Note that the RegEx engine has a special "meta character" that covers "A-Z0-9" AND the underscore "_" which is "\w" and means 'Any word character'.
#>
# Type the new pattern for the $pat variable below by replacing the question mark "?" with the correct expression, then execute the selection to test this pattern to verify it is 'True'.
$pat = "?"
"A" -match $pat 

# Answer: "[\w.%+-]"

<#
So far, we've tested single character patterns. In a RegEx pattern of the form “[set]+”, the trailing “+” demands that one or more occurrences of the items in the set must be present for the match to be true. 
We now want to test the pattern for multiple characters, so we will use this. 
#>
# Type the new pattern for the $pat variable below by replacing the question mark "?" with the correct expression, then execute the selection to test this pattern to verify it is 'True'.
$pat = "?"
"user" -match $pat 
$matches 
# NOTE:  The match returns True with and without the trailing ‘+’, however, the matched output in $matches contains ‘u’ without the ‘+’ and ‘user’ with the ‘+’ 
# Answer: [\w.%+-]+

<#
    For some string "user@contoso.com" your pattern will the "user" component. 
    Test this by using the following code in the ISE, altering the “user” string to various series of letters and numbers. 
    A match will show as True. View the output of $matches to show which piece of the string was matched. 
#>
# Type the new pattern for the $pat variable below by replacing the question mark "?" with the correct expression you used from the previous task, then execute the selection to test this pattern to verify it is 'True'.
$pat = "?"
"user@contoso.com" -match $pat 
$matches

# Answer: "[\w.%+-]+"

# Now replace the evaluation string of "user@contoso.com" to "username@contoso.com" and execute the test again. This time, the username component should be reflected in the $matches variable.
$pat = "?"
"username@contoso.com" -match $pat 
$matches

<#
    5. Next, the “@” is part of a legal email string.  
    This is a plain character with no escape required.  
    Add this character "@" to the previous pattern.  
    You now have a "user@" pattern which we can test.
#>
# Type the new complete pattern for the $pat variable below by replacing the question mark "?" with the correct expression you used from the previous task, then execute the selection to test this pattern to verify it is 'True'.
$pat = "?"
"user@whatever" -match $pat 
$matches

# Answer: "[\w.%+-]+@"

<#
    Now for a pattern to match the contoso piece of our general form of string, user@contoso.com. 
    We shall use a “[set]+” again, but this time with fewer of the special chars (just a dash is also allowed). 
    Let this take the form "[A-Z-]+". Combine this with our earlier pattern. 
#>
# Type the new complete pattern for the $pat variable below by replacing the question mark "?" with the correct expression you used from the previous task, then execute the selection to test this pattern to verify it is 'True'.

$pat = "?" 
"user@whatever" -match $pat 
$matches

# If you have typed this pattern correctly, $matches will show “user@whatever”. You have created the patterns needed to match with "user@contoso". 
# However, an email address is usually in the form user@contoso.com or user@contoso.com.au. 

# Answer: "[\w.%+-]+@[A-Z-]+" 

<#
 Lastly, we need a grouping of the pattern of “.XXX” where the XX must be of two or more characters, minimum. We say this with "[A-Z]{2,}". 
 However, we are not quite finished. 
 We need to tell the pattern that there is a dot. Because a dot can have special meaning within RegEx patterns, we will escape it so that it is treated as a plain character.  
 You escape the dot via the backslash.  
 This piece of our pattern would now be "\.[A-Z]{2,}".  Test this by trying various .co or .com strings. 
#>
# Type the new complete pattern for the $pat variable below by replacing the question mark "?" with the correct expression you used from the previous task, then execute the selection to test this pattern to verify it is 'True'.
$pat = "?" 
".com" -match $pat 
$matches

# Answer: "\.[A-Z]{2,}" 

<#
8. At this point your combined pattern sets would be capable of matching user@contoso.com and return True. 
We are nearly there. Test this. 
#>
$pat = "?" 
"user@contoso.com" -match $pat 
$matches

# Answer: "[\w.%+-]+@[A-Z-]+\.[A-Z]{2,}" 

<#
9. You may well expect one or more of these .XXX groups, for a legitimate email address like “user@contoso.net.au” or “user@contoso.co.uk”. 
To do this, wrap it in round brackets and say "+" to this final group. Recall that the "+" in this context means "1 or more". 
This gives us "(\.[A-Z]{2,})+". Test this new sub-pattern
#>

$pat = "(\.[A-Z]{2,})+" 
".com.au" -match $pat 
$matches 

<#
10. If you see True, then all the pieces of our pattern are ready to fit together. Concatenate them all into one pattern as below. 
$pattern = '[\w.%+-]+@[A-Z-]+(\.[A-Z]{2,})+' 
#>

# Exeucte the following code by selecting in and pressing F8 to run the selection, then observe the results.

#5.1.1.ps1 
$pattern = '[\w.%+-]+@[A-Z-]+(\.[A-Z]{2,})+' 
$text = "Email the team at ToTheCloud@contoso.com " 
$text += "and also AzureMigrate@contoso.net.au " 
$text += "and lastly O365team@contoso.eu" 
 
Function MatchMe ($pattern) 
{   
    Process 
    { 
        $_ | Select-String -AllMatches $pattern |       
        ForEach-Object { 
            $_.Matches.Value 
        } # end foreach  
    } # end process
} # end function

Clear-Host Write-Output "" 
Write-Output "Searching: '$text'" 
Write-Output "Using pattern '$pattern'" 
Write-Output " "   
$text | MatchMe $pattern 
 
#endregion 5.1.2

#region 5.1.4: A RegEx pattern to rename multiple files

<#
You have a folder on a video server that contains thousands of corporate training videos with a complicated naming system. 
The request has come in to copy them to another location with a simpler name format.  

1. The filenames take the form “The.Workplace.S24E01.HDTV.x264-LOL.mp4” and the desired name should be “The Workplace S24E01.mp4”. 

2. To pattern-match the source we shall need to identify a literal “.” within the string. The meta-character to escape the dot is “\.”. 

3. We also need to identify “any normal word characters” The meta-character for that is “\w”. 

4. We will also need to identify 2-digit numbers to extract the “S24E01” region. We saw in an earlier task that “\d{2}” will achieve that. 

5. The matching regions we wish to retain can be named specifically. We saw how to do that in an earlier task. The form is (?<NAME>pattern). 

6. There are three regions of the filenames that are of interest. The first we might call the PROGRAM. The second we might refer to as the EPISODE and the final piece is the EXTENSION. 

7. The file extension is always at the end of the filename. We can also leverage the “$” meta-character to specify a pattern match at the end of the string. 

8. The start of the pattern will need to take the form “one or more of anything ".+" and then a dot”. The “dot” operator says “anything except a <newline>”. We will use “.+” to say “one or 
more of anything”, then an actual dot, via “\.”. We are looking to match the string “The.Workplace.” Within the ISE, execute the code below and confirm that it returns True. 
#>

$pattern="(?<PROGRAM>.+\.)” 
“The.Workplace.” –Match $pattern 
$matches

<#
    9. The second block of the filename we wish to match is the EPISODE region. 
       We can describe this as “any normal word characters, then a two-digit number, some more characters and then another two-digit number”. 
       The meta-character for “any word character” is “\w”.  We can combine that with the “+” operator to say “one or more”, and this would look like “\w+”.  
       We already know from earlier tasks that a 2-digit number can be described with “\d{2}”. 
       So we can create an appropriate NAMED block using these patterns combined as below. Confirm it returns True
#>

$pattern="(?<EPISODE>\w+\d{2}\w+\d{2})“ 
“S24E01” –Match $pattern 
$matches 

<#
    10. We wish to effectively discard the “anything else” between the <EPISODE> and the file extension. 
        We can do that readily with the “.+” pattern, which we used in a similar way for the <PROGRAM> region. 
#>
$pattern = "(.+)"
<#
    11. So finally we come to the end of the filename. 
        We wish to say “anything from the last dot to the end”. 
        We can say “\.”, we can say “\w+” for “anything” and we can state that this last pattern must match the end of the string by using the “$”.
#>

$pattern=”(?<EXTENSION>\.\w+$)” 
“anything.mp4” –Match $pattern 
$matches

<#
    12. Combining these four pattern blocks into one to gives the final RegEx pattern. 
#>

$pattern = "(?<PROGRAM>.+\.)(?<EPISODE>\w+\d{2}\w+\d{2})(.+)(?<EXTENSION>\.\w+$)"

<#
    13. Notice the C:\Pshell\Labs\Lab_5\videos folder contains two video files: The.Workplace.S24E01.HDTV.x264-LOL.mp4 and The.Workplace.S24E02.HDTV.x264-LOL.mp4 
    14. Select the code below and press F8 to execute the selection in the ISE.  
    
    5.1.4.ps1
    A folder contains numerous training videos in the form "The.Workplace.S24E01.HDTV.x264-LOL.mp4"
    that you want to rewrite as "The Workplace S24E01.mp4"
#>

$pattern = "(?<PROGRAM>.+\.)(?<EPISODE>\w+\d{2}\w+\d{2})(.+)(?<EXTENSION>\.\w+$)"
$folder = "C:\PShell\Labs\Lab_5\videos"
Write-Output "Current directory list before processing..."
Get-ChildItem -Path $folder
Get-ChildItem -Path $folder | ForEach-Object {
    if ($_.Name -match $pattern)
    {
        $NewFileName = ($matches.program).Replace("."," ") + $matches.episode + $matches.extension
        $NewFileFullName = Join-Path -Path $_.DirectoryName -ChildPath $NewFileName
        Copy-Item -Path $_.FullName -Destination $NewFileFullName -Verbose -Force
    } # end if
} # end foreach
Write-Output "Current directory list before processing..."
Get-ChildItem -Path $folder

#endregion 5.1.4
#endregion 5.1