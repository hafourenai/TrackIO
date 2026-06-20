allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    // Set namespace + compileSdk for library subprojects (required by AGP 8+)
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                if (namespace == null) {
                    namespace = "com.example.${project.name}"
                }
                if (compileSdk == null || compileSdk!! < 34) {
                    compileSdk = 34
                }
            }
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
