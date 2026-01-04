import java.util.Properties
import org.gradle.api.tasks.Delete

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.social.coachLife.android"
    compileSdk = 36
ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.social.coachLife.android"
        minSdk = 24
        targetSdk = 36
        versionCode = project.findProperty("flutter.versionCode")?.toString()?.toInt() ?: 1
        versionName = project.findProperty("flutter.versionName")?.toString() ?: "1.0"
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
            storeFile = keystoreProperties["storeFile"]?.toString()?.let { file(it) }
            storePassword = keystoreProperties["storePassword"]?.toString()
        }
        getByName("debug") {
            // default debug signing
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
isShrinkResources = false

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packagingOptions {
        resources {
            pickFirsts.add("lib/arm64-v8a/libaosl.so")
            pickFirsts.add("lib/armeabi-v7a/libaosl.so")
            pickFirsts.add("lib/x86/libaosl.so")
            pickFirsts.add("lib/x86_64/libaosl.so")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.0")
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    implementation("com.microsoft.clarity:clarity:3.0.0")
    implementation("com.github.tiktok:tiktok-business-android-sdk:1.3.8")
    implementation("com.android.billingclient:billing:6.1.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

afterEvaluate {
    tasks.named("mapDebugSourceSetPaths").configure {
        mustRunAfter("processDebugGoogleServices")
    }
    tasks.named("mapReleaseSourceSetPaths").configure {
        mustRunAfter("processReleaseGoogleServices")
    }
    tasks.named("mergeReleaseResources").configure {
        dependsOn("processReleaseGoogleServices")
    }
}
