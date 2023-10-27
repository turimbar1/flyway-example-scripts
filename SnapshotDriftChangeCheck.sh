## drift report pre-deployment snapshot of shadow
flyway snapshot -url=$(Shadow_JDBC_URL) -user=$(shadow_username) -password=$(shadow_password) -snapshot.filename="C:\snapshots\VCurrent_snapshot"

## deploy to Shadow
## flyway migrate -url=$(Shadow_JDBC_URL) -user=$(shadow_username) -password=$(shadow_password)

## take snapshot for change report - how does deployment change objects in shadow to estimate changes in target db
flyway snapshot -url=$(Shadow_JDBC_URL) -user=$(shadow_username) -password=$(shadow_password) -snapshot.filename="C:\snapshots\VNext_snapshot"

## Use snapshots for Drift and Change reports
flyway info check -drift -changes -dryrun -code -check.deployedSnapshot="C:\snapshots\VCurrent_snapshot" -check.nextSnapshot="C:\snapshots\VNext_snapshot" -check.failOnDrift="$(Boolean)" -schemas="$(schemas)" -url="$(target_database_JDBC)" -user="$(userName)" -password="$(password)" -check.reportFilename="$(System.ArtifactsDirectory)\$(databaseName)-$(Build.BuildId)-DriftReport.html" -licenseKey=$(FLYWAY_LICENSE_KEY) -workingDirectory="$(WORKING_DIRECTORY)"