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
