plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.diet_app"
    compileSdk = 35  // ✅ Updated from flutter.compileSdkVersion

    // ✅ NDK version maintained
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.diet_app"
        minSdk = 24  // Updated to support flutter_sound library
        targetSdk = 35  // ✅ Updated from flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enable renderscript support for better image processing performance
        renderscriptTargetApi = 24
        renderscriptSupportModeEnabled = true

        // Enable wide gamut color space for better camera quality
        vectorDrawables.useSupportLibrary = true
    }

    // ✅ Added aaptOptions block for TFLite files
    aaptOptions {
        noCompress.add("tflite")  // Prevents compression of TensorFlow Lite models
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
