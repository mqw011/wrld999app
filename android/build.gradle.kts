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

    project.evaluationDependsOn(":app")

    // Workarounds for AGP 8.x + Kotlin 2.x compatibility with old plugins
    pluginManager.withPlugin("com.android.library") {
        val androidExt = extensions.findByName("android")
            as? com.android.build.gradle.LibraryExtension ?: return@withPlugin

        // Fix missing namespace from manifest package attribute
        if (androidExt.namespace == null) {
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val factory = javax.xml.parsers.DocumentBuilderFactory.newInstance()
                val doc = factory.newDocumentBuilder().parse(manifestFile)
                val pkg = doc.documentElement.getAttribute("package")
                if (pkg.isNotBlank()) {
                    androidExt.namespace = pkg
                }
            }
        }

        // Fix JVM target consistency (Java must match Kotlin target)
        androidExt.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
        androidExt.compileOptions.targetCompatibility = JavaVersion.VERSION_17
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
