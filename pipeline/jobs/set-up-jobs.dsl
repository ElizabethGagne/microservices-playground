String mainFolder = 'POC'
String projectFolder = 'microservices-test'
String basePath = mainFolder + "/" +  projectFolder
String gitRepo = 'sni/microservices-playground'
String gitUrl = 'git@bitbucket.org:' + gitRepo

workflowJob("$basePath/1. pre-configure") {
  	scm {
        git("$gitUrl")
    }

    parameters {
        stringParam('GIT_URL' , "$gitUrl", 'Git repository url of your application.')
        stringParam('BUCKET_NAME', 'sni-eureka', 'Bucket name to receive cloud formation templates.')
    }

    definition {
        cps {
            script(readFileFromWorkspace('pipeline/jobs/PreConfigure.groovy'))
            sandbox()
        }
    }
}

workflowJob("$basePath/2. create-deployment") {
  	scm {
        git("$gitUrl")
    }

    parameters {
        stringParam('GIT_URL' , "$gitUrl", 'Git repository url of your application.')
        stringParam('BUCKET_NAME', 'sni-eureka', 'Bucket name to receive cloud formation templates.')
        stringParam('KEY_NAME', 'hybrid-d', 'AWS .pem key used to create resources.')
        stringParam('HOSTED_ZONE_NAME', 'awsdev.snops.net', 'Domain Name for your Application.')
        choiceParam('LOG_COLLECTOR', ['cloudwatch', 'sumologic'], 'Log Collector to use.')
    }

    definition {
        cps {
            script(readFileFromWorkspace('pipeline/jobs/Infrastructure.groovy'))
            sandbox()
        }
    }
}

workflowJob("$basePath/3. update-weather-service") {
  	scm {
        git("$gitUrl")
    }

    triggers {
        bitbucketPush()
    }

    parameters {
        stringParam('GIT_URL' , "$gitUrl", 'Git repository url of your application.')
    }

    definition {
        cps {
            script(readFileFromWorkspace('pipeline/jobs/WeatherService.groovy'))
    	    sandbox()
        }
    }
}
