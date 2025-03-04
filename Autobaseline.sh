#!/bin/bash 

  

########### To generate new baseline and schema-model, update WorkingFolderPath to a new location may be something with app name,Url,Password, Schemas 

  

set -euo pipefail 

  

  

# Set the working folder path 

export DOTNET_ROOT=/opt/ddl_automation/OEL8/flyway-desktop-7.6.2/dotnet 

export PATH=${PATH}:/etc:/usr/lib:/usr/lib64:/usr/local/bin:/sys_bckup/reel/bin:/usr/etc:/usr/bin/X11:/etc/conf/bin:/oracle/local/bin:/opt/ddl_automation/OEL8/flyway-10.17.1:/opt/ddl_automation/instantclient_19_15:/opt/ddl_automation/OEL8/flyway-desktop-7.6.2/flyway-dev:/opt/ddl_automation/OEL8/flyway-desktop-7.6.2/dotnet 

  

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

#Url="jdbc:oracle:thin:@//hOst200-scan.heronet.int:1527/PDBCDPCS10A" 

Url="$DBBASELINEURL" 

User="$DBUSER" 

Password="$DBPWD" 

Schemas="$SCHEMAS" # May be '' for SqlServer or '"Schema1", "Schema2"' for Oracle 

echo $SCHEMAS 

  

# Set the paths 

ArtifactPath="$WorkingFolderPath/artifact.zip" 

ProjectPath="$WorkingFolderPath/flyway.toml" 

MigrationPath="$WorkingFolderPath/migrations" 

  

# Create a project 

flyway-dev init -n Autobaseline -p "$WorkingFolderPath" --database-type "$DatabaseType" --i-agree-to-the-eula 

echo -e "\n\n[environments.development]\nurl = \"some-url\"\nschemas = [$Schemas]"" >> "$ProjectPath" 

echo -e "\n\n[environments.target]\nurl = "$Url"\nschemas = [$Schemas]\nuser = "$User"\npassword = "$Password"" >> "$ProjectPath" 

sed -i 's/includeStoragePartitioning = false/includeStoragePartitioning = true/g' "$ProjectPath" 

sed -i 's/ignoreSupplementalLogGroups = false/ignoreSupplementalLogGroups = true/g' "$ProjectPath" 

sed -i 's/ignorePermissions = true/ignorePermissions = false/g' "$ProjectPath" 

  

# schema model diffs 

###DiffOptions=$(cat <<-END 

###{ "url": "$Url", "user": "$User", "password": "$Password", "schemas": [$Schemas], "resolverProperties": [] } 

###END 

###) 

  

  

flyway-dev diff -p "$ProjectPath" -a "$ArtifactPath" --targetId target --from Target --to SchemaModel --i-agree-to-the-eula 

  

#apply to schema model 

flyway-dev take -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula \ 

  | flyway-dev apply -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula 

  

flyway-dev diff -p "$ProjectPath" -a "$ArtifactPath" --targetId target --from Target --to Empty --i-agree-to-the-eula 

  

# Generate the baseline from all differences 

flyway-dev take -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula \ 

  | flyway-dev generate -p "$ProjectPath" -a "$ArtifactPath" -o "$MigrationPath" --name 'B1__script.sql' --versioned-only --i-agree-to-the-eula 

  

echo -e "\n[flyway.oracle]\nsqlplus = true" >> "$ProjectPath"
