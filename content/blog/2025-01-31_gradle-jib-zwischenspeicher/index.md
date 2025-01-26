JIB-Projekt

```
./gradlew jibBuildTar
```

lädt das Basisimage herunter und speichert das "neue" Image
unter "build/jib-image.tar".

Wiederholte Ausführung geht "schnell".

Wo wird das Basisimage zwischengespeichert?

```
uli@uliip5:~/git/github/uli-heller/java-example-jib$ find . -size +40M
./build/jib-image.tar
uli@uliip5:~/git/github/uli-heller/java-example-jib$ find ~/.gradle -size +40M
/home/uli/.gradle/caches/modules-2/files-2.1/org.rocksdb/rocksdbjni/7.9.2/6409b667493149191b09fe1fce94bada6096a3e9/rocksdbjni-7.9.2.jar
/home/uli/.gradle/wrapper/dists/gradle-8.12-bin/cetblhg4pflnnks72fxwobvgv/gradle-8.12/lib/kotlin-compiler-embeddable-2.0.21.jar
/home/uli/.gradle/wrapper/dists/gradle-8.11.1-bin/bpt9gzteqjrbo1mjrsomdt32c/gradle-8.11.1/lib/kotlin-compiler-embeddable-2.0.20.jar
uli@uliip5:~/git/github/uli-heller/java-example-jib$ find ~/.cache -size +40M
/home/uli/.cache/google-cloud-tools-java/jib/layers/587b49ab5385c6f5be0e6991c10019ab858a1af9825c21ccdda057797d644f80/99e3c800615e51a23ebb5c4c7982a1d5288504a1ccef4e6a9b78930b67b791d6
/home/uli/.cache/trivy/java-db/trivy-java.db
/home/uli/.cache/trivy/db/trivy.db
```

Also: In "/home/uli/.cache/google-cloud-tools-java/jib/layers"


Erste Erzeugung des Container-Images
------------------------------------

```
java-example-jib$ ./gradlew --console=plain jibBuildTar
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes

> Task :jibBuildTar
Tagging image with generated image reference java-example-jib:0.0.2. If you'd like to specify a different tag, you can set the jib.to.image parameter in your build.gradle, or use the --image=<MY IMAGE> commandline flag.

Containerizing application to file at '/home/uli/git/github/uli-heller/java-example-jib/build/jib-image.tar'...
Base image 'eclipse-temurin:17-jre' does not use a specific image digest - build may not be reproducible
Getting manifest for base image eclipse-temurin:17-jre...
Building dependencies layer...
Building snapshot dependencies layer...
Building classes layer...
Building jvm arg files layer...
The base image requires auth. Trying again for eclipse-temurin:17-jre...
Using base image with digest: sha256:38e0afc86a10bf4cadbf1586fb617b3a9a4d09c9a0be882e29ada4ed0895fc84
Container entrypoint set to [java, -cp, @/app/jib-classpath-file, Main]
Building image to tar file...

Built image tarball at /home/uli/git/github/uli-heller/java-example-jib/build/jib-image.tar

BUILD SUCCESSFUL in 31s
2 actionable tasks: 1 executed, 1 up-to-date
```

```
java-example-jib$ ./gradlew --console=plain jibBuildTar
> Task :compileJava UP-TO-DATE
> Task :processResources NO-SOURCE
> Task :classes UP-TO-DATE
> Task :jibBuildTar UP-TO-DATE

BUILD SUCCESSFUL in 741ms
2 actionable tasks: 2 up-to-date
```

```
java-example-jib$ rm build/jib-image.tar
java-example-jib$ ./gradlew --console=plain jibBuildTar
> Task :compileJava UP-TO-DATE
> Task :processResources NO-SOURCE
> Task :classes UP-TO-DATE

> Task :jibBuildTar
Tagging image with generated image reference java-example-jib:0.0.2. If you'd like to specify a different tag, you can set the jib.to.image parameter in your build.gradle, or use the --image=<MY IMAGE> commandline flag.

Containerizing application to file at '/home/uli/git/github/uli-heller/java-example-jib/build/jib-image.tar'...
Base image 'eclipse-temurin:17-jre' does not use a specific image digest - build may not be reproducible
Getting manifest for base image eclipse-temurin:17-jre...
Building dependencies layer...
Building snapshot dependencies layer...
Building classes layer...
Building jvm arg files layer...
The base image requires auth. Trying again for eclipse-temurin:17-jre...
Using base image with digest: sha256:38e0afc86a10bf4cadbf1586fb617b3a9a4d09c9a0be882e29ada4ed0895fc84

Container entrypoint set to [java, -cp, @/app/jib-classpath-file, Main]
Building image to tar file...

Built image tarball at /home/uli/git/github/uli-heller/java-example-jib/build/jib-image.tar

BUILD SUCCESSFUL in 5s
2 actionable tasks: 1 executed, 1 up-to-date
```

Probleme
--------

### Read timed out

```
java-example-jib$ ./gradlew --console=plain jibBuildTar
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes

> Task :jibBuildTar
Tagging image with generated image reference java-example-jib:0.0.2. If you'd like to specify a different tag, you can set the jib.to.image parameter in your build.gradle, or use the --image=<MY IMAGE> commandline flag.

Containerizing application to file at '/home/uli/git/github/uli-heller/java-example-jib/build/jib-image.tar'...
Base image 'eclipse-temurin:17-jre' does not use a specific image digest - build may not be reproducible
Getting manifest for base image eclipse-temurin:17-jre...
Building dependencies layer...
Building snapshot dependencies layer...
Building classes layer...
Building jvm arg files layer...
The base image requires auth. Trying again for eclipse-temurin:17-jre...
Using base image with digest: sha256:38e0afc86a10bf4cadbf1586fb617b3a9a4d09c9a0be882e29ada4ed0895fc84
I/O error for image [registry-1.docker.io/library/eclipse-temurin]:
    java.net.SocketTimeoutException
    Read timed out
I/O error for image [registry-1.docker.io/library/eclipse-temurin]:
    java.net.SocketTimeoutException
    Read timed out

> Task :jibBuildTar FAILED

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':jibBuildTar'.
> com.google.cloud.tools.jib.plugins.common.BuildStepsExecutionException: Read timed out

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 38s
2 actionable tasks: 2 executed
```

Abhilfe: Wiederholen!
