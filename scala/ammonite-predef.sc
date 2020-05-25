// Circe for JSON mangling
import $ivy.`io.circe::circe-generic:0.13.0`
import $ivy.`io.circe::circe-parser:0.13.0`
// STTP for the quick HTTP request
import $ivy.`com.softwaremill.sttp.client::core:2.1.1`
import $ivy.`com.softwaremill.sttp.client::circe:2.1.1`

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

// My prompt
repl.prompt.bind {
  import java.util.regex.Pattern.quote
  val now = java.time.LocalTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"))
  val shortpwd = wd.toString
    .replaceFirst(s"\\A${quote(home.toString)}", "~")
    .replaceAll("(\\.?[^/])[^/]*/", "$1/")
  s"$shortpwd at $now\nλ "
}
interp.colors().prompt() = fansi.Color.LightMagenta
