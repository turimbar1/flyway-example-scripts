#!/bin/bash

 

########### To generate new baseline and schema-model, update WorkingFolderPath to a new location may be something with app name,Url,Password, Schemas

 

set -euo pipefail

 

 

# Set the working folder path

export DOTNET_ROOT=/opt/ddl_automation/OEL8/flyway-desktop-7.2.1/dotnet #TODO Change this to Current flyway version

export PATH=${PATH}:/etc:/usr/lib:/usr/lib64:/usr/local/bin:/sys_bckup/reel/bin:/usr/etc:/usr/bin/X11:/etc/conf/bin:/oracle/local/bin:/opt/ddl_automation/OEL8/flyway-10.15.2:/opt/ddl_automation/instantclient_19_15:/opt/ddl_automation/OEL8/flyway-desktop-7.2.1/flyway-dev:/opt/ddl_automation/OEL8/flyway-desktop-7.2.1/dotnet

 

export PROGRAM=$1

echo $PROGRAM

 

export CRQ=$2

echo $CRQ

 

 

# Set the working folder path

WorkingFolderPath="/ddl_automation/Automated_Onboarding/"$PROGRAM"/$CRQ/Baselinemodel"

 

export DBTYPE=$3

echo $DBTYPE

 

export DBBASELINEURL=$4

echo $DBBASELINEURL

 

export DBUSER=$5

echo $DBUSER

 

export DBPWD=$6

echo $DBPWD

 

export SCHEMAS=$7

echo $SCHEMAS

 

# Set the database type and database connection properties

DatabaseType="$DBTYPE" # alt values: SqlServer Oracle PostgreSql

Url="$DBBASELINEURL"

User="$DBUSER"

Password="$DBPWD"

Schemas="$SCHEMAS" # May be '' for SqlServer or '"Schema1", "Schema2"' for Oracle

echo $SCHEMAS



# Set the project file path

ProjectPath="$WorkingFolderPath/flyway.toml"



# Create a project

flyway init -init.projectName="Autobaseline" -workingDirectory="$WorkingFolderPath" -init.databaseType="$DatabaseType" --i-agree-to-the-eula


# Set Datatase comparison options

sed -i 's/includeStoragePartitioning = false/includeStoragePartitioning = true/g' "$ProjectPath"

sed -i 's/ignoreSupplementalLogGroups = false/ignoreSupplementalLogGroups = true/g' "$ProjectPath"

sed -i 's/ignorePermissions = true/ignorePermissions = false/g' "$ProjectPath"

 
# Create a schema model from the target environment

flyway diff model -workingDirectory="$WorkingFolderPath""-diff.source=dev" "-diff.target=schemaModel" "-environments.dev.url=$Url" "-environments.dev.user=$User" "-environments.dev.password=$Password" "-environments.dev.schemas=$Schemas"


# Generate the diff script between baseline and schema model

flyway diff generate -workingDirectory="$WorkingFolderPath" "-diff.source=schemaModel" "-diff.target=empty" "-generate.types=baseline" "-generate.version=1" 

echo -e "\n[flyway.oracle]\nsqlplus = true" >> "$ProjectPath"
