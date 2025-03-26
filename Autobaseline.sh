#!/bin/bash

set -euo pipefail

########## To generate a new baseline and schema-model, update WorkingFolderPath to a new location, maybe something with app name, Url, Password, Schemas

export PROGRAM=$1
echo $PROGRAM

export CRQ=$2
echo $CRQ

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

# Set PATH
# TODO Change below to Current flyway version
export PATH=${PATH}:/etc:/usr/lib:/usr/lib64:/usr/local/bin:/sys_bckup/reel/bin:/usr/etc:/usr/bin/X11:/etc/conf/bin:/oracle/local/bin:/opt/ddl_automation/OEL8/flyway-10.15.2:/opt/ddl_automation/instantclient_19_15

# Set the working folder and project file path
WorkingFolderPath="/ddl_automation/Automated_Onboarding/"$PROGRAM"/$CRQ/Baselinemodel"
ProjectPath="$WorkingFolderPath/flyway.toml"

# Set the database type and database connection properties
DatabaseType="$DBTYPE" # alt values: SqlServer Oracle PostgreSql
Url="$DBBASELINEURL"
User="$DBUSER"
Password="$DBPWD"
Schemas="$SCHEMAS" # May be '' for SqlServer or '"Schema1", "Schema2"' for Oracle

# Authenticate flyway
export FLYWAY_EMAIL=insertEmailHere
export FLYWAY_TOKEN=insertTokenHere

# Create a project
flyway init -init.projectName="$SCHEMAS" -init.databaseType="$DatabaseType" -workingDirectory="$WorkingFolderPath"

# Set Datatase comparison options
sed -i 's/includeStoragePartitioning = false/includeStoragePartitioning = true/g' "$ProjectPath"
sed -i 's/ignoreSupplementalLogGroups = false/ignoreSupplementalLogGroups = true/g' "$ProjectPath"
sed -i 's/ignorePermissions = true/ignorePermissions = false/g' "$ProjectPath"

# Create a schema model from the target environment
flyway diff model -workingDirectory="$WorkingFolderPath" "-diff.source=dev" "-diff.target=schemaModel" "-environments.dev.url=$Url" "-environments.dev.user=$User" "-environments.dev.password=$Password" "-environments.dev.schemas=$Schemas"

# Generate the diff script between baseline and schema model
flyway diff generate -workingDirectory="$WorkingFolderPath" "-diff.source=schemaModel" "-diff.target=empty" "-generate.types=baseline" "-generate.version=1"