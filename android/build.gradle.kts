allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Fix for libraries missing namespace (e.g. flutter_ringtone_player)
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            try {
                val android = extensions.findByName("android")!!
                
                // Force compileSdkVersion to 36 to fix lStar error
                val setCompileSdkVersion = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdkVersion.invoke(android, 36)
                
                // Force targetSdkVersion to 36
                val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                val setTargetSdkVersion = defaultConfig.javaClass.getMethod("targetSdkVersion", Int::class.javaPrimitiveType)
                setTargetSdkVersion.invoke(defaultConfig, 36)

                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    var ns = group.toString()
                    if (ns == "null" || ns.isEmpty()) {
                        ns = "com.example.${project.name}"
                    }
                    setNamespace.invoke(android, ns)
                }
            } catch (e: Exception) {
                // Ignore
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}