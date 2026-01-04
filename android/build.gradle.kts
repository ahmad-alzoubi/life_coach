import org.gradle.api.tasks.Delete

buildscript {
    // لا يوجد ext في Kotlin DSL، نستخدم val
    val kotlin_version by extra("2.1.0")

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // START: FlutterFire Configuration
        classpath("com.google.gms:google-services:4.3.10")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.8.1")
        // END: FlutterFire Configuration
    }
}

allprojects {
    repositories {
        maven { setUrl("https://repo.agora.io/repository/maven") }
        google()
        mavenCentral()
        maven { setUrl("https://jitpack.io") } // For any JitPack dependencies
    }
}

// إعادة تحديد buildDir للمشاريع الفرعية
rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

// task clean
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
