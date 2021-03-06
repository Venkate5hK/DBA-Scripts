#SQL Script Generator Template
#Author: Ayo Ijidakinro
#Date: 09/01/2012


#Declare SQL objects to script
<#  The script will crawl all objects that are a member of the schema(s) listed in $schemas and
    the roles listed in $roles. Either $schemas or $roles can be empty. 
    
    When creating a new script from this template, simply change $schemas and $roles to declare
    the objects you would like the script to emit.
#>

#========================================================
# CHANGE THE BELOW VARIABLES TO CONTROL SCRIPT GENERATION
#========================================================

[string[]]$schemasToScript = @( "dbo" )
[string[]]$rolesToScript = @()
[string]$fileWithTablesRelativePath = ".D:\DBObjects\DEVSQL" #This should be a relative path of form, ..\..\somedir1\somedir2\somedirn
[string]$fileWithoutTablesRelativePath = ".D:\DBObjects\DEVSQL" #This should be a relative path of form, ..\..\somedir1\somedir2\somedirn
[string]$servername = "DEVSQL" #The db and server to connect to. By default this script uses windows auth.
[string]$dbname = "DBAMaint"

#===========================
# END OF CONFIGURABLE REGION
#===========================

#
#
#

<#  The below triggers script generation. The below rows 
    should remain unchanged. #>

. ".\SqlScriptGenerationHelperScripts\ScriptGenerationMethods.ps1" <# Loads functions into memory that will 
                                                                      handle the script generation and prepare 
                                                                      the .NET environment #>

$fileWithTables = [System.IO.Path]::GetFullPath($fileWithTablesRelativePath) #Convert the relative path into a usable path.
$fileWithoutTables = [System.IO.Path]::GetFullPath($fileWithoutTablesRelativePath) #Convert the relative path into a usable path.

Write-Host "Writing script with tables to path: $fileWithTables"

GenerateSqlWithTables $schemasToScript $rolesToScript $fileWithTables $servername $dbname <#  Now we call the main function 
                                                                                              that will do that actual 
                                                                                              scripting. #>
                                                                                    
Write-Host "Writing script without tables to path: $fileWithoutTables"

GenerateSqlWithoutTables $schemasToScript $rolesToScript $fileWithoutTables $servername $dbname <#  Now we call the main function 
                                                                                                    that will do that actual 
                                                                                                    scripting. #>