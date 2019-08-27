// Add kind projector plugin for type lambdas
import $ivy.`org.typelevel::cats-core:2.0.0-RC2`
import $ivy.`com.chuusai::shapeless:2.3.3`
import $ivy.`io.circe::circe-generic:0.12.0-RC4`
import $ivy.`io.circe::circe-parser:0.12.0-RC4`

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
