// Cancel executions with C-c
cancelable in Global := true

// A workaround to show plugin updates
addCommandAlias("outdatedPlugins",
                "; reload plugins; dependencyUpdates; reload return")

// I can never remember this command
addCommandAlias("outdated", "dependencyUpdates")

// I can never remember these either
addCommandAlias("ls", "projects")
addCommandAlias("cd", "project")

// Work around https://github.com/coursier/coursier/issues/450
import coursier.Keys._
classpathTypes += "maven-plugin"
