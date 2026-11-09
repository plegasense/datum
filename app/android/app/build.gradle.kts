import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val defaultSigningDirectory = file(
    "${System.getProperty("user.home")}/Library/Application Support/Dovexa/signing",
)
val keystorePropertiesFile = System.getenv("DATUM_KEY_PROPERTIES")
    ?.let(::file)
    ?: File(defaultSigningDirectory, "key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

android {
    namespace = "app.datum.datum"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.datum.datum"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Open CASCADE solo está compilado para arm64: sin esto Gradle empaqueta libdartjni
        // de x86_64/armeabi-v7a y Play ofrece la app a dispositivos donde no arranca.
        ndk { abiFilters += "arm64-v8a" }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { path ->
                val configuredFile = File(path)
                if (configuredFile.isAbsolute) configuredFile else File(defaultSigningDirectory, path)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    packaging {
        jniLibs { excludes += listOf("lib/x86_64/**", "lib/x86/**", "lib/armeabi-v7a/**") }
    }

    buildTypes {
        release {
            // Sin clave de subida (otro equipo) se firma con la de depuración para poder probar.
            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release")
            else signingConfigs.getByName("debug")
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
