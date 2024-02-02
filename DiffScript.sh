#!/bin/bash
set -euo pipefail

# Point to where flyway dev is
# If you didn't create the entrypoint script you may need to invoke flyway dev through dotnet
# e.g. /opt/flyway-desktop/dotnet/dotnet /opt/flyway-desktop/flyway-dev/flyway-dev.dll
#flyway-dev() {
#    /opt/flyway-desktop/flyway-dev.sh --i-agree-to-the-eula "$@"
#}

# Set the working folder path
WorkingFolderPath=~/.

#Set the environment (eg Dev, QA, Test) database connection properties
Url="jdbc:oracle:thin:@//localhost:1521/Dev1"
User="HR"
Password="Password"
Schemas='"HR"' # May be '' for SqlServer or '"Schema1", "Schema2"' for Oracle

# Set the shadow (empty) database connection properties
ShadowUrl="jdbc:oracle:thin:@//localhost:1521/Dev1"
ShadowUser="HR"
ShadowPassword="Password"


# Set the paths
ArtifactPath="/tmp/artifact.zip"
ProjectPath="$WorkingFolderPath/flyway.toml"
ProjectUserPath="$WorkingFolderPath/flyway.user.toml"
MigrationPath="$WorkingFolderPath/migrations"

# schema model diffs
DiffOptions=$(cat <<-END
{ "url": "$Url", "user": "$User", "password": "$Password", "schemas": [$Schemas], "resolverProperties": [] } 
END
)

#adding shadow env to flyway.user.toml config for migration generation
echo -e "\n\n[environments.shadow]\nurl = \"$ShadowUrl\"\nuser = \"$ShadowUser\"\npassword = \"$ShadowPassword\"\nschemas = [$Schemas]\nprovisioner = \"clean\"" >> "$ProjectPath"

echo "$DiffOptions" \
  | flyway-dev diff -p "$ProjectPath" -a "$ArtifactPath" --from Target --to SchemaModel --i-agree-to-the-eula

#apply to schema model
flyway-dev take -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula \
  | flyway-dev apply -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula

#diff between schema model and shadow/migrations scripts
#echo "$ShadowDiffOptions" \
flyway-dev diff -p "$ProjectPath" -a "$ArtifactPath" --from SchemaModel --to Micrations --i-agree-to-the-eula

# Generate the diff script between baseline and this environment
flyway-dev take -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula \
  | flyway-dev generate -p "$ProjectPath" -a "$ArtifactPath" -o "$MigrationPath" --i-agree-to-the-eula

#mark scripts as deployed to target environment
# flyway migrate info -skipExecutingMigrations="true" -url="$Url" -user="$User" -password="$Password" -workingDirectory="$WorkingFolderPath" -cleanDisabled="false" -schemas="$Schemas" -baselineOnMigrate="true"