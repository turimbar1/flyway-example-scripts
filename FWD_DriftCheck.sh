#!/bin/bash
set -euo pipefail

# Point to where flyway dev is
# If you didn't create the entrypoint script you may need to invoke flyway dev through dotnet
# e.g. /opt/flyway-desktop/dotnet/dotnet /opt/flyway-desktop/flyway-dev/flyway-dev.dll
flyway-dev() {
    /opt/flyway-desktop/flyway-dev.sh --i-agree-to-the-eula "$@"
}

WorkingFolderPath=~/.

Url="jdbc:oracle:thin:@//localhost:1521/Dev1"
User="HR"
Password="Password"
Schemas='"HR"' # May be '' for SqlServer or '"Schema1", "Schema2"' for Oracle

# Set the paths
ArtifactPath="/tmp/artifact.zip"
ProjectPath="$WorkingFolderPath/flyway.toml"
MigrationPath="$WorkingFolderPath/migrations"

# schema model diffs
DiffOptions=$(cat <<-END
{ "url": "$Url", "user": "$User", "password": "$Password", "schemas": [$Schemas], "resolverProperties": [] } 
END
)

echo "$DiffOptions" \
  | flyway-dev diff -p "$ProjectPath" -a "$ArtifactPath" --from SchemaModel --to Target

