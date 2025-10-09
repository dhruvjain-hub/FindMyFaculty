plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Firebase plugin must be last
}

android {
    namespace = "com.example.my_app"
    compileSdk = 36 // ✅ Use numeric value to satisfy plugin requirements

    defaultConfig {
        applicationId = "com.example.my_app"
        minSdk = flutter.minSdkVersion         // ✅ Use numeric value
        targetSdk = 36      // ✅ Use numeric value to match compileSdk
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ Firebase BOM automatically manages versions
    implementation(platform("com.google.firebase:firebase-bom:32.1.2"))

    // ✅ Firebase libraries without specifying versions
    implementation("com.google.firebase:firebase-analytics-ktx:21.5.0")
    implementation("com.google.firebase:firebase-auth-ktx:22.3.0")
    implementation("com.google.firebase:firebase-firestore-ktx:24.10.0")
}

flutter {
    source = "../.."
}

repositories {
    google()
    mavenCentral()
}
