# Session: Spring Boot CLI App (Gradle)

**Datum:** 2026-09-08
**Ort:** `/home/ubuntu/shared-with-host/springboot`

## Auftrag

1. Spring Boot **Command Line Application** (kein Web) mit **gradlew** als Build-Tool anlegen.
2. Durchweg die **neuesten Versionen** aller verwendeten Komponenten.
3. Ergänzend: `io.spring.dependency-management` entfernen und stattdessen das **Spring Boot BOM** verwenden.

## Umgebung

- Ubuntu 26.04 LTS (x86_64), initiauell ohne Java/Gradle
- Installiert: `openjdk-26-jdk-headless` → **OpenJDK 26.0.2** (neueste LTS im Repo)
- Projektgerüst via **start.spring.io** (Initializr) generiert = Ground Truth für die neuesten Versionen

## Verwendete Versionen (aktuellste)

| Komponente | Version |
|---|---|
| Spring Boot (Plugin) | **4.1.1** |
| Gradle (Wrapper) | **9.7.1** |
| Java (Toolchain) | **26** |
| Spring Framework (via BOM) | 7.0.9 |
| `SpringBootPlugin.BOM_COORDINATES` | spring-boot-dependencies:4.1.1 |

## Projektstruktur

```
build.gradle
settings.gradle               # rootProject.name = 'cli-app'
gradlew / gradlew.bat
gradle/wrapper/gradle-wrapper.{jar,properties}   # Gradle 9.7.1
src/main/java/com/example/cliapp/CliApplication.java     # @SpringBootApplication, main()
src/main/java/com/example/cliapp/GreetingRunner.java     # ApplicationRunner (CLI-Logik)
src/main/resources/application.properties                # web-application-type=none
src/test/java/com/example/cliapp/CliApplicationTests.java
```

## build.gradle (Finalstand)

```groovy
plugins {
	id 'java'
	id 'org.springframework.boot' version '4.1.1'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(26)
	}
}

repositories {
	mavenCentral()
}

dependencies {
	implementation platform(org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES)
	implementation 'org.springframework.boot:spring-boot-starter'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
	testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

tasks.named('test') {
	useJUnitPlatform()
}
```

**Wichtig:** `io.spring.dependency-management` wurde auf Wunsch entfernt.
Versionen kommen explizit aus dem BOM:
`implementation platform(org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES)`
(Konstante aus dem Boot-Plugin vorhanden — via `javap` im Plugin-Jar 4.1.1 verifiziert.)

## CLI-Verhalten

- `GreetingRunner` (ApplicationRunner):
  - Option `--name=<name>` (Default: `World`)
  - Positionale Argumente werden aufgelistet
  - Gibt Spring Boot-Version, Java-Version, Zeitstempel aus
- Nicht-Web-App (`spring.main.web-application-type=none`) → Context startet, Runner läuft, App beendet sich sauber

## Verifikation (alles erfolgreich)

- `./gradlew clean build` → BUILD SUCCESSFUL (Compile + Test, Context-Load auf Java 26)
- `./gradlew bootRun` → `Hello, World!`, Spring Boot 4.1.1, Java 26.0.2
- `./gradlew bootRun --args="--name=Alice deploy --environment=production"`
  → `--name`/`--environment` als Optionen, `deploy` als Positional korrekt erkannt
- `java -jar build/libs/cli-app-0.0.1-SNAPSHOT.jar --name=BOM` → läuft standalone
- `./gradlew dependencies --configuration runtimeClasspath` → Versionen aus BOM (z. B. spring-core 7.0.9)

## Befehle

```bash
./gradlew build                       # kompilieren + tests
./gradlew bootRun                     # starten ohne Argumente
./gradlew bootRun --args="--name=Du"  # starten mit Argumenten
java -jar build/libs/cli-app-0.0.1-SNAPSHOT.jar --name=Du
```

## Zeitliche Abläufe / Entscheidungen

1. Keine Java/Gradle-Installation → `openjdk-26-jdk-headless` per apt installiert.
2. `start.spring.io/metadata` lieferte 404 → Versionen stattdessen über generiertes Starter-Zip + `actuator/info` ermittelt (Initializr 0.25.0, Boot 4.1.1).
3. Starter standardmäßig auf Java-Toolchain 17 → auf 26 angehoben ("latest and greatest"); funktioniert.
4. `io.spring.dependency-management` gegen explizites BOM-`platform()` getauscht; Clean Build + Laufzeit bestätigt Auflösung.
