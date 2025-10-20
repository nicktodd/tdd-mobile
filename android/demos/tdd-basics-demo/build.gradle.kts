plugins {
    kotlin("jvm") version "1.9.22"
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.9.2")
    testImplementation("org.mockito:mockito-core:5.1.1")
    testImplementation("org.mockito.kotlin:mockito-kotlin:4.1.0")

    // KoTest dependencies
    testImplementation("io.kotest:kotest-runner-junit5:5.7.2") // For running tests
    testImplementation("io.kotest:kotest-assertions-core:5.7.2") // For assertions

    // MockK dependency
    testImplementation("io.mockk:mockk:1.13.0")
}

tasks.test {
    useJUnitPlatform()
}
