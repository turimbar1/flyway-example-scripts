# Set the database type and database connection properties
$databaseType = "SqlServer" # alt values: SqlServer Oracle PostgreSql MySql 
$Url = "jdbc:sqlserver://localhost;databaseName=NewWorldDB_Dev;encrypt=false;integratedSecurity=true;trustServerCertificate=true"
$User = ""
$Password = ""
$projectName = "Autobaseline"

# Set the schemas value
$schemas = @("") # can be empty for SqlServer

mkdir $projectName
cd ./$projectName
flyway init "-init.projectName=$projectName" "-init.databaseType=$databaseType"
flyway diff model "-diff.source=dev" "-diff.target=schemaModel" "-environments.dev.url=$Url" "-environments.dev.user=$User" "-environments.dev.password=$Password" "-environments.dev.schemas=$schemas"
flyway diff generate "-diff.source=schemaModel" "-diff.target=empty" "-generate.types=baseline" "-generate.version=1.0.0" 
