// Add kind projector plugin for type lambdas
import $plugin.$ivy.`org.spire-math::kind-projector:0.9.9`
import $ivy.`org.typelevel::cats-core:1.5.0`
import $ivy.`com.chuusai::shapeless:2.3.3`
import $ivy.`io.cirice::circe-core:0.10.0`
import $ivy.`io.cirice::circe-generic:0.10.0`
import $ivy.`io.cirice::circe-parser:0.10.0`

// Load ammonite-shell for this ammonite version
interp.load.ivy(
  "com.lihaoyi" %
  s"ammonite-shell_${scala.util.Properties.versionNumberString}" %
  ammonite.Constants.version
)

@
val shellSession = ammonite.shell.ShellSession()
import shellSession._
import ammonite.ops._
import ammonite.shell._
ammonite.shell.Configure(interp, repl, wd)

// Enable partial unification
interp.configureCompiler(_.settings.YpartialUnification.value = true)
