#!/bin/bash
set -euo pipefail

# Set the working folder path
WorkingFolderPath="~/databases/example-project"

# Set the database type and database connection properties
DatabaseType="Oracle" # alt values: SqlServer Oracle PostgreSql 
Url="jdbc:oracle:thin:@//localhost:1521/Dev1"
User="HR"
Password="Redg@te1"

# Set the schema value
Schema="HR" # can be empty for SqlServer

# Set the artifact and migration paths
ArtifactPath=""$WorkingFolderPath"/artifact.zip"
MigrationPath=""$WorkingFolderPath"/migrations"

# Create a project
flyway-dev init \
    -n Autobaseline \
    -p "$WorkingFolderPath" \
    --database-type "$DatabaseType" \
    --i-agree-to-the-eula

DiffOptions="{ \
        ""url"": ""$Url"", \
        ""user"": ""$User"", \
        ""password"": ""$Password"", \
        ""token"": null, \
        ""schemas"": ["$Schema"], \
        ""resolverProperties"": [] }"

$SchemaDiffs = $DiffOptions | \
    flyway-dev diff \
        -p "$WorkingFolderPath" \
        -a ""$ArtifactPath"2" \
        --from Target \
        --to SchemaModel \
        --output json \
        --i-agree-to-the-eula

echo $schemaDiffs.differences.id | \
    flyway-dev apply \
    -p "$WorkingFolderPath" \
        -a ""$ArtifactPath"2" \
        --from Target \
        --to SchemaModel \
        --output json \
        --i-agree-to-the-eula

echo $DiffOptions | \
    flyway-dev diff \
        -p "$WorkingFolderPath" \
        -a "$ArtifactPath" \
        --from Target \
        --to Empty \
        --output json \
        --i-agree-to-the-eula

# Generate the baseline from all differences
flyway-dev take \
    -p "$WorkingFolderPath" \
    -a "$ArtifactPath" \
    --i-agree-to-the-eula | \
        flyway-dev generate \
            -p "$WorkingFolderPath" \
            -a "$ArtifactPath" \
            -o "$MigrationPath" \
            --name 'B1__script.sql' \
            --versioned-only \
            --i-agree-to-the-eula