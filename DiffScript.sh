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
MigrationPath="$WorkingFolderPath/migrations"

# schema model diffs
DiffOptions=$(cat <<-END
{ "url": "$Url", "user": "$User", "password": "$Password", "schemas": [$Schemas], "resolverProperties": [] } 
END
)

ShadowDiffOptions=$(cat <<-END
{ "url": "$ShadowUrl", "user": "$ShadowUser", "password": "$ShadowPassword", "schemas": [$Schemas], "resolverProperties": [] } 
END
)


echo "$DiffOptions" \
  | flyway-dev diff -p "$ProjectPath" -a "$ArtifactPath" --from Target --to SchemaModel --i-agree-to-the-eula

#apply to schema model
flyway-dev take -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula \
  | flyway-dev apply -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula

#deploy migrations to shadow
flyway clean migrate info -url="$ShadowUrl" -user="$ShadowUser" -password="$ShadowPassword" -workingDirectory="$WorkingFolderPath" -cleanDisabled="false" -schemas="$Schemas" -baselinOnMigrate="true"

#diff between schema model and shadow/migrations scripts
echo "$ShadowDiffOptions" \
  | flyway-dev diff -p "$ProjectPath" -a "$ArtifactPath" --from SchemaModel --to Target --i-agree-to-the-eula

# Generate the diff script between baseline and this environment
flyway-dev take -p "$ProjectPath" -a "$ArtifactPath" --i-agree-to-the-eula \
  | flyway-dev generate -p "$ProjectPath" -a "$ArtifactPath" -o "$MigrationPath" --i-agree-to-the-eula