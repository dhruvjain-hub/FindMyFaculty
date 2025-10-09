// Top-level build.gradle.kts

buildscript {
    repositories {
        google()      // ✅ Required for Firebase and Google Services
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.1") // Android Gradle plugin
        classpath("com.google.gms:google-services:4.4.0")  // ✅ Required for Firebase plugin
    }
}

allprojects {
    repositories {
        google()      // ✅ Must include Google repo
        mavenCentral()
    }
}

// Optional: redirect build outputs if you have a custom setup
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Ensure the app module is evaluated first
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
