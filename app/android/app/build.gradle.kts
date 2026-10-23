import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Auto-generate project-local debug keystore on D: drive if missing
val debugKeystoreFile = file("debug.keystore")
if (!debugKeystoreFile.exists()) {
    try {
        val javaHome = System.getProperty("java.home")
        val isWindows = System.getProperty("os.name").lowercase().contains("win")
        val keytoolCandidate = File(javaHome, if (isWindows) "bin/keytool.exe" else "bin/keytool")
        val keytoolBin = if (keytoolCandidate.exists()) keytoolCandidate.absolutePath else "keytool"

        println("VanRozgar: Auto-generating debug.keystore at ${debugKeystoreFile.absolutePath}...")
        val proc = ProcessBuilder(
            keytoolBin,
            "-genkeypair",
            "-v",
            "-keystore", debugKeystoreFile.absolutePath,
            "-storepass", "android",
            "-alias", "androiddebugkey",
            "-keypass", "android",
            "-keyalg", "RSA",
            "-keysize", "2048",
            "-validity", "10000",
            "-dname", "CN=Android Debug,O=Android,C=US"
        ).start()

        val exitCode = proc.waitFor()
        if (exitCode == 0) {
            println("VanRozgar: Successfully generated debug.keystore")
        } else {
            val err = proc.errorStream.bufferedReader().readText()
            println("VanRozgar: keytool exited with code $exitCode: $err")
        }
    } catch (e: Exception) {
        println("VanRozgar: Could not auto-generate debug.keystore: ${e.message}")
    }
}

android {
    namespace = "com.example.vanrozgar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "org.vanrozgar.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            keyAlias = "androiddebugkey"
            keyPassword = "android"
            storePassword = "android"
            storeFile = debugKeystoreFile
        }
        create("release") {
            // Production keystore configuration:
            // When key.properties is provided, use real keystore for Play Store
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val properties = Properties()
                keystorePropertiesFile.inputStream().use { properties.load(it) }
                keyAlias = properties.getProperty("keyAlias")
                keyPassword = properties.getProperty("keyPassword")
                storeFile = file(properties.getProperty("storeFile"))
                storePassword = properties.getProperty("storePassword")
            } else {
                // Fallback to debug keystore for development / pilot demo
                initWith(signingConfigs.getByName("debug"))
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
