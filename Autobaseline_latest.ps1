mkdir Autobaseline
cd ./Autobaseline
flyway init "-init.projectName=Autobaseline" "-init.databaseType=SqlServer"
flyway diff model "-diff.source=dev" "-diff.target=schemaModel" "-environments.dev.url=jdbc:sqlserver://localhost;databaseName=NewWorldDB_Dev;encrypt=false;integratedSecurity=true;trustServerCertificate=true"
flyway diff generate "-diff.source=schemaModel" "-diff.target=empty" "-generate.types=baseline" "-generate.version=1.0.0" 