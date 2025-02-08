# Define the source and target directories relative to the current directory
$sourceDir = ".\schema-model"
$targetDir = ".\migrations"

# Create the target directory if it doesn't exist
if (-Not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir
}

# Get all .sql files from the source directory and its subdirectories
$sqlFiles = Get-ChildItem -Path $sourceDir -Recurse -Filter *.sql

foreach ($file in $sqlFiles) {
    # Define the new file name with the "R__" prefix
    $newFileName = "R__" + $file.Name
    # Define the target file path
    $targetFilePath = Join-Path -Path $targetDir -ChildPath $newFileName
    # Copy the file to the target directory with the new name
    Copy-Item -Path $file.FullName -Destination $targetFilePath
}

Write-Output "SQL scripts have been copied and renamed successfully."

# Run the Flyway command and capture the output
$flywayCommand = 'flyway check -code -reportEnabled=true -workingDirectory="C:\Repos\Solera" -environment=development  -reportFilename="RegEx_Rules_report.html" -configFiles="C:\Repos\Solera\flyway.toml,C:\Repos\Solera\flyway.user.toml"'
$flywayOutput = Invoke-Expression $flywayCommand

# Output the Flyway command results to the console
Write-Output $flywayOutput

Write-Output "Flyway check command executed successfully."

# Delete the newly copied files
#$copiedFiles = Get-ChildItem -Path $targetDir -Filter "R__*.sql"
#foreach ($copiedFile in $copiedFiles) {
#    Remove-Item -Path $copiedFile.FullName -Force
#}

#Write-Output "Newly copied SQL scripts have been deleted successfully."