// Cancel executions with C-c
Global / cancelable := true

// Clear screen when watching sources
triggeredMessage := Watched.clearWhenTriggered

// Clear screen command
commands += Command.command("clear") { state =>
  print("\033c")
  state
}

// Don't resolve snapshot dependencies again and again
updateOptions := updateOptions.value.withLatestSnapshots(false)

// Enable semantic DB for IDEA
// Global / semanticdbEnabled := true

// I can never remember this command.
addCommandAlias("outdated", "dependencyUpdates")

// A workaround to show plugin updates
addCommandAlias("outdatedPlugins",
                "; reload plugins; dependencyUpdates; reload return")

// Make SBT shell a bit more like a regular shell to keep my muscle memory
// working
addCommandAlias("ls", "projects")
addCommandAlias("ll", "projects")
addCommandAlias("cd", "project")

// Inspect Java version and Java Home of the running shell to figure out what
// JDK I’m running on currently.
addCommandAlias("javaVersion", """eval System.getProperty("java.version")""")
addCommandAlias("javaHome", """eval System.getProperty("java.home")""")

// Get the name of the underlying runtime, because it contains the PID which
// comes handy if you’d like to inspect the SBT shell w/ visualvm
addCommandAlias("runtimeName", "eval java.lang.management.ManagementFactory.getRuntimeMXBean().getName()")
// Only for JDK 9 or newer
addCommandAlias("runtimePID", "eval ProcessHandle.current().pid()")
