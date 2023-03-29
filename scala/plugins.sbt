// Generate a graph of all projects in the build and their dependencies
addSbtPlugin("com.dwijnand" % "sbt-project-graph" % "0.4.0")

// Check for missing or unused dependencies
addSbtPlugin("com.github.cb372" % "sbt-explicit-dependencies" % "0.2.9")

addDependencyTreePlugin
