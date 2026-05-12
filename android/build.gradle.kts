allprojects {
    repositories {
        google()
        mavenCentral()
        jcenter()
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
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ---------------------------------------------------------------------------
// Fix for isar_flutter_libs 3.1.0+1 — missing namespace with AGP 8+
// Uses pluginManager.withPlugin so it hooks before evaluation, avoiding
// the "project already evaluated" error from afterEvaluate.
// ---------------------------------------------------------------------------
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            if (namespace == null) {
                namespace = group.toString()
            }
        }
    }
}