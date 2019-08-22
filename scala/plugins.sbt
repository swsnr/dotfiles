// Generate a graph of all projects in the build and their dependencies
addSbtPlugin("com.dwijnand" % "sbt-project-graph" % "0.4.0")

// General project statistics (loc, no classes, etc)
addSbtPlugin("com.orrsella" %% "sbt-stats" % "1.0.7")

// Print all licenses used by dependencies
addSbtPlugin("com.typesafe.sbt" % "sbt-license-report" % "1.2.0")

// Dependency management: Get a list or graph of all dependencies, and find
// updates for installed dependencies
addSbtPlugin("net.virtual-void" % "sbt-dependency-graph" % "0.10.0-RC1")

// Check for missing or unused dependencies
addSbtPlugin("com.github.cb372" % "sbt-explicit-dependencies" % "0.2.9")

// Bloop build tool, see https://scalacenter.github.io/bloop/
addSbtPlugin("ch.epfl.scala" % "sbt-bloop" % "1.3.2")
