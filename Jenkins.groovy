// This is an example of a Declarative Pipeline using Flyway in a Jenkinsfile.
// This example uses a self-hosted Windows agent.  The Flyway command line will need to be installed on the agent.
// See the Redgate documentation for downloading the command line or for a Jenkinsfile with Linux and other examples.
// You might also want to consider using the Flyway Docker image - https://hub.docker.com/r/redgate/flyway.

 

String gitRepoUri = 'https://git-codecommit.us-east-1.amazonaws.com/v1/repos/WarehouseProductsDBTest'

 

pipeline {
   agent {
      label "jenkinsnode4-sandbox" // Specifying a label is optional. However, can be valuable to ensure only specific agents are used.
   }
   environment {
      myProjectName = "WarehouseProductsDBTest" // Specify the name of your project, this will be used in the directory structure; this must match the name of your folder for the Flyway project that contains the migrations folder
      buildDirectory = "C:\\Build\\Jenkins\\${env.myProjectName}\\Build-${BUILD_NUMBER}" // Directory location for build files to be written to
      releaseName = "Build_${env.BUILD_NUMBER}"
      FLYWAY_LICENSE_KEY = "${env.ENV_FLYWAY_LICENSE}" // Enter your Flyway Teams license here. For added security, this could also be passed in as a secure environment variable if required.

   }

   stages { //this stage should target the SHADOW DATABASE - script: "flyway clean" command is cleanup everything in the target DB and deploy everything in the project.
      stage('Git pull') {
        steps {
            deleteDir() /* delete the workspace before pulling source code */
            git credentialsId: 'CodeCommit-HTTPS', url: gitRepoUri
        }
      }
      stage('Build') {
         environment {
            databaseHost = "DBDEV3" // Database Host Address for Build Database
            databasePort = "1433" // Database Port for Build Database
            databaseInstance = "" // Optional - Database Instance for Build Database
            databaseName = "WarehouseProductsShadow" // Build Database Name - {env.STAGE_NAME} will take the active stage name to append to DB name
            databaseUsername = "${env.flywayUser}" // Add Username If Applicable  flyway_user is common username
            // databasePassword = credentials('flywaypwd') // Add Password If Applicable. For security, this could be entered within Jenkins credential manager and called.
            flywayJDBC = "-url=jdbc:sqlserver://${env.databaseHost};databaseName=${env.databaseName};instanceName=${env.databaseInstance};integratedSecurity=true" //to the end of this string if you do not require a Username/Password
            flywayLocations = "-locations=filesystem:\"${env.buildDirectory}\\${env.myProjectName}\\migrations\"" // This is the location of the local cloned GIT repo. {env.WORKSPACE} refers to the Jenkins Agent workspace area. It might be necessary to add some sub-folders to point to the migrations folder

 

         }
         steps {
            echo 'Carrying Out Build Activities'

 

            dir("${env.buildDirectory}")

 

            echo "Current stage is - ${env.STAGE_NAME}"

 

            echo "Running Flyway Build Script"

 

            script {

 

               echo "Running Flyway Build using Username and Password"
               def buildStatus
               buildStatus = bat returnStatus: true, label: "Run Flyway Build Process Against: ${env.DatabaseName}", script: "flyway clean migrate info ${env.flywayJDBC} ${env.flywayLocations} -user=\"${env.databaseUsername}\" -password=\"${env.databasePassword}\" -cleanDisabled=\"true\" " // Clean disabled is needed in build environments if you're running a clean build from scratch each time  

 

               echo "Status of Running CI build: $buildStatus"
               if (buildStatus != 0) {
                  error('Running CI build failed')
               }
            }
         }
      }
   }
}