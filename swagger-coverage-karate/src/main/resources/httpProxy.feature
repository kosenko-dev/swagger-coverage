@ignore
Feature: Http Proxy for Swagger-Coverage

Background:
    * print 'init target url:', destUrl
    * print 'using oas3:', oas3
    * print 'working Dir:', workingDir

    * def initWriter = 
    """
        function(dir){
            var RequestWriter = Java.type('com.github.viclovsky.swagger.coverage.RequestWriter');
            return new RequestWriter(dir);
        }
    """
    * def writer = callonce initWriter workingDir
    * def scOptions = Java.type("com.github.viclovsky.swagger.coverage.SwaggerCoverageOptions");

Scenario: scOptions.getIgnoreCall()
    * print "Call ignored for Swagger Coverage Report."
    * karate.proceed(destUrl)
    * scOptions.reset()

Scenario:
    * karate.proceed(destUrl)
    
    * def pathParams = pathMatches(scOptions.getPathPattern()) ? pathParams : null
    
    * def multipart = karate.get('requestParts', null)
    * if (multipart != null) karate.remove("multipart", ".[*].value")

    * def reqJson = 
    """
        {
            baseUrl: '#(requestUrlBase)',
            path: '#(requestUri)',
            requestParams: '#(requestParams)',
            headerParams: '#(requestHeaders)',
            responseHeaders: '#(responseHeaders)',
            requestParts: '#(multipart)',
            pathParams: '#(pathParams)',
            method: '#(requestMethod)',
            statusCode: '#(responseStatus)',
            hasBody: '#(request != null)'
        }
    """

    * def coverageRequest = karate.toBean(reqJson, 'com.github.viclovsky.swagger.coverage.Request')
    * eval writer.write(coverageRequest, oas3)
    * scOptions.reset()
