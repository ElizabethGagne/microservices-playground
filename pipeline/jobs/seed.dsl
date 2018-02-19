String mainFolder = 'POC'
String projectFolder = 'microservices-test'
String basePath = mainFolder + "/" +  projectFolder
String gitRepo = 'sni/microservices-playground'
String gitUrl = 'git@bitbucket.org:' + gitRepo


folder("$mainFolder") {
    description 'POC Folder'
}

folder("$basePath") {
    description 'microservices-test'
}

// If you want, you can define your seed job in the DSL and create it via the REST API.
// See README.md

job("$basePath/0. seed") {
    scm {
        git("$gitUrl")
    }
    triggers {
        scm 'H/5 * * * *'
    }
    steps {
        dsl {
            external 'pipeline/jobs/set-up-jobs.dsl'
            additionalClasspath 'src/main/groovy'
        }
    }
}