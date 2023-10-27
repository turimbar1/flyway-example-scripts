# Set the working folder path
$workingFolderPath = "C:\WorkingFolders\test"

# Set the database type and database connection properties
$databaseType = "Oracle" # alt values: SqlServer Oracle PostgreSql 
$Url = "jdbc:oracle:thin:@//localhost:1521/Dev1"
$User = "HR"
$Password = "Redg@te1"

# Set the schemas value
$schemas = @("HR") # can be empty for SqlServer

# Set the artifact and migration paths
$artifactPath = Join-Path $workingFolderPath "artifact.zip"
$migrationPath = Join-Path $workingFolderPath "migrations"

# Create a project (SQL Server)
flyway-dev init -n Autobaseline -p $workingFolderPath --database-type $databaseType --i-agree-to-the-eula

# Read the JSON file
$jsonPath = Join-Path $workingFolderPath "flyway-dev.json"
$json = Get-Content -Path $jsonPath | ConvertFrom-Json

# Add a new key-value pair to the JSON
$newKey= "schemas"
$newValue = $schemas
$json | Add-Member -MemberType NoteProperty -Name $newKey -Value $newValue

$devDB = @{
    "connectionProvider" = @{
        "type" = "UsernamePassword"
        "url" = "some-url"
    }
}

$json | Add-Member -MemberType NoteProperty -Name "developmentDatabase" -Value $devDB

# Write out the updated JSON
$json | ConvertTo-Json | Set-Content -Path $jsonPath

# Get the differences from Production
$diffOptions = @{
    "url" = $Url
    "user" = $User
    "password" = $Password
    "token" = $null
    "schemas" = $schemas
    "resolverProperties" = @()
}

$diffOptions | ConvertTo-Json | flyway-dev diff -p $workingFolderPath -a $artifactPath --from Target --to Empty --output json --i-agree-to-the-eula

# Generate the baseline from all differences
flyway-dev take -p $workingFolderPath -a $artifactPath --i-agree-to-the-eula | flyway-dev generate -p $workingFolderPath -a $artifactPath -o $migrationPath --name 'B1__script.sql' --versioned-only --i-agree-to-the-eula
