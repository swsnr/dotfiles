# My dotfiles

Build with [dotbot][].  Highlights:

* [Fish shell][] configuration.
* [Git][] configuration.
* [SBT][] configuration.
* [Powershell][] configuration.

[dotbot]: https://github.com/anishathalye/dotbot
[fish shell]: https://fishshell.com
[git]: https://git-scm.com
[sbt]: https://www.scala-sbt.org
[powershell]: https://msdn.microsoft.com/en-us/powershell

## Install

```console
$ git clone --recurse-submodules https://github.com/lunaryorn/dotfiles.git
$ cd dotfiles
$ brew bundle  # On macOS
$ ./install.py  # On all systems
$ scripts/rustup.py  # Further setup scripts as needed
```

Needs Python 3.2 or newer.

## License

Copyright 2018-2019 Sebastian Wiesner

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at <http://www.apache.org/licenses/LICENSE-2.0>.

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
