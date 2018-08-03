// Generate a graph of all projects in the build and their dependencies
addSbtPlugin("com.dwijnand" % "sbt-project-graph" % "0.4.0")

// General project statistics (loc, no classes, etc)
addSbtPlugin("com.orrsella" %% "sbt-stats" % "1.0.7")

// Print all licenses used by dependencies
addSbtPlugin("com.typesafe.sbt" % "sbt-license-report" % "1.2.0")

// Show dependencies updates
addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.3.4")

// Dependency management: Get a list or graph of all dependencies, and find
// updates for installed dependencies
addSbtPlugin("net.virtual-void" % "sbt-dependency-graph" % "0.9.0")
