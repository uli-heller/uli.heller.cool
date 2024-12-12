gradle-artifactory
==================

Dies ist ein kleines Java-Projekt, welches
das Build-Tool "Gradle" zusammen mit dem
Artifactory-Plugin verwendet. Es soll nur
demonstrieren, dass das Artifactory-Plugin
den Namen des veröffentlichten Artefakts ausgibt.

Das Veröffentlichen scheitert danach, weil ich
keinen Artifactory-Server verwende. Ist für
die Ausgabe aber relativ uninteressant.

Hier der Ablauf:

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-artifactory$ ./gradlew artifactoryPublish
> Task :compileJava UP-TO-DATE
> Task :processResources NO-SOURCE
> Task :classes UP-TO-DATE
> Task :jar UP-TO-DATE
> Task :generateMetadataFileForJavaPublication
> Task :generatePomFileForJavaPublication
> Task :artifactoryPublish
> Task :extractModuleInfo
[pool-3-thread-1] Deploying artifact: file:/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-artifactory/build/local-repository/artifactory/cool/heller/gradle-artifactory/1.0-SNAPSHOT/gradle-artifactory-1.0-SNAPSHOT.jar
> Task :artifactoryDeploy FAILED
[Incubating] Problems report is available at: file:///home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-artifactory/build/reports/problems/problems-report.html

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':artifactoryDeploy'.
> java.util.concurrent.ExecutionException: java.lang.RuntimeException: org.apache.http.client.ClientProtocolException: URI does not specify a valid host name: file:/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-artifactory/build/local-repository/artifactory/cool/heller/gradle-artifactory/1.0-SNAPSHOT/gradle-artifactory-1.0-SNAPSHOT.jar;build.timestamp=1734043778954;build.name=gradle-artifactory;build.number=1734043778968

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.

You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.

For more on this, please refer to https://docs.gradle.org/8.11.1/userguide/command_line_interface.html#sec:command_line_warnings in the Gradle documentation.

BUILD FAILED in 498ms
7 actionable tasks: 5 executed, 2 up-to-date
```
