# <span id="top">Playing with Dafny on Windows</span>

<table style="font-family:Helvetica,Arial;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="https://dafny.org/" rel="external"><img src="docs/images/dafny-logo.jpg" width="120" alt="Dafny project"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    This repository gathers <a href="https://dafny.org/" rel="external" title="Dafny">Dafny</a> code examples coming from various websites.<br/>
    It also includes several build scripts (<a href="https://www.gnu.org/software/bash/manual/bash.html" rel="external">bash scripts</a>, <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting" rel="external">batch files</a>, <a href="https://makefiletutorial.com/" rel="external">Make scripts</a>) for experimenting with <a href="https://dafny.org/" rel="external">Dafny</a> on a Windows machine.
  </td>
  </tr>
</table>

[Ada][ada_examples], [Akka][akka_examples], [C++][cpp_examples], [COBOL][cobol_examples], [Dart][dart_examples], [Deno][deno_examples], [Docker][docker_examples], [Flix][flix_examples], [Golang][golang_examples], [GraalVM][graalvm_examples], [Haskell][haskell_examples], [Kafka][kafka_examples], [Kotlin][kotlin_examples], [LLVM][llvm_examples], [Modula-2][m2_examples], [Node.js][nodejs_examples], [Rust][rust_examples], [Scala 3][scala3_examples], [Spark][spark_examples], [Spring][spring_examples], [TruffleSqueak][trufflesqueak_examples], [WiX Toolset][wix_examples] and [Zig][zig_examples] are other topics we are continuously monitoring.

## <span id="proj_deps">Project dependencies</span>

- [Dafny 4.8][dafny_downloads] ([*release notes*][dafny_relnotes])
- [Git 2.47][git_downloads] ([*release notes*][git_relnotes])
- [Microsoft .NET 6.0 SDK][dotnet_sdk_downloads] ([*release notes*][dotnet_sdk_relnotes])

Optionally one may also install the following software:

- [ConEmu 2023][conemu_downloads] ([*release notes*][conemu_relnotes])
- [Dafny for Visual Studio Code 3.4](https://github.com/dafny-lang/ide-vscode) ([*release notes*][ide-vscode_relnotes])
- [Visual Studio Code 1.94][vscode_downloads] ([*release notes*][vscode_relnotes])

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a [Windows installer][windows_installer]. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`][unix_opt] directory on Unix).

For instance our development environment looks as follows (*October 2024*) <sup id="anchor_01">[1](#footnote_01)</sup>:

<pre style="font-size:80%;">
C:\opt\ConEmu\                        <i>( 26 MB)</i>
C:\opt\Git\                           <i>(389 MB)</i>
C:\opt\dafny\                         <i>(133 MB)</i>
C:\opt\VSCode\                        <i>(374 MB)</i>
C:\Program Files\dotnet\sdk\6.0.425\  <i>(324 MB)</i>
</pre>

> **:mag_right:** [Git for Windows][git_downloads] provides a Bash emulation used to run [**`git`**][git_cli] from the command line (as well as over 250 Unix commands like [**`awk`**][man1_awk], [**`diff`**][man1_diff], [**`file`**][man1_file], [**`grep`**][man1_grep], [**`more`**][man1_more], [**`mv`**][man1_mv], [**`rmdir`**][man1_rmdir], [**`sed`**][man1_sed] and [**`wc`**][man1_wc]).


## <span id="structure">Directory structure</span> [**&#x25B4;**](#top)

This project is organized as follows:

<pre style="font-size:80%;">
bin\
docs\
examples\{<a href="./examples/README.md">README.md</a>, <a href="./examples/Competition/">Competition</a>, <a href="./examples/Fibonacci/">Fibonacci</a>, ..}
README.md
<a href="setenv.bat">setenv.bat</a>
</pre>

where

- directory [**`bin\`**](bin/) contains utility tools.
- directory [**`docs\`**](docs/) contains [Dafny] related documents.
- directory [**`examples\`**](examples/) contains [Dafny] code examples (see [`README.md`](examples/README.md) file).
- file **`README.md`** is the [Markdown][github_markdown] document for this page.
- file [**`setenv.bat`**](setenv.bat) is the batch command for setting up our environment.

## <span id="commands">Batch commands</span> [**&#x25B4;**](#top)

### **`setenv.bat`** <sup id="anchor_04">[4](#footnote_04)</sup>

We execute command [**`setenv`**](setenv.bat) once to setup our development environment; it makes external tools such as [**`git.exe`**][git_cli] and [**`sh.exe`**][sh_cli] directly available from the command prompt.

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a></b>
Tool versions:
   dafny 4.8.1,
   git 2.47.0, diff 3.10, bash 5.2.37(1)

<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1" rel="external">where</a> git sh</b>
C:\opt\Git\bin\git.exe
C:\opt\Git\mingw64\bin\git.exe
C:\opt\Git\bin\sh.exe
C:\opt\msys64\usr\bin\sh.exe
C:\opt\Git\usr\bin\sh.exe
</pre>

Command [**`setenv`**](./setenv.bat)`-verbose` also prints :
- the tool paths.
- the environment variables defined in the current session.
- the path associations (globally defined).

<pre style="font-size:80%;">
<b>&gt; <a href="./setenv.bat">setenv</a> -verbose</b>
Tool versions:
   dafny 4.8.1,
   git 2.47.0, diff 3.10, bash 5.2.37(1)
Tool paths:
   C:\opt\dafny\Dafny.exe
   C:\opt\Git\bin\git.exe
   C:\opt\Git\usr\bin\diff.exe
   C:\opt\Git\bin\bash.exe
Environment variables:
   "DAFNY_HOME=C:\opt\dafny"
   "GIT_HOME=C:\opt\Git"
   "JAVA_HOME=C:\opt\jdk-temurin-17.0.10_7"
Path associations:
   G:\: => %USERPROFILE%\workspace-perso\dafny-examples
</pre>
<!--=======================================================================-->

## <span id="footnotes">Footnotes</span> [**&#x25B4;**](#top)

<span id="footnote_01">[1]</span> ***Downloads*** [↩](#anchor_01)

<dl><dd>
In our case we downloaded the following installation files (<a href="#proj_deps">see section 1</a>):
</dd>
<dd>
<pre style="font-size:80%;">
<a href="https://github.com/dafny-lang/dafny/releases" rel="external">dafny-4.8.1-x64-windows-2019.zip</a>   <i>(60 MB)</i>
<a href="https://dotnet.microsoft.com/en-us/download/dotnet/6.0" rel="external">dotnet-sdk-6.0.425-win-x64.exe</a>    <i>(194 MB)</i>
<a href="https://git-scm.com/download/win" rel="external">PortableGit-2.47.0-64-bit.7z.exe</a>   <i>(55 MB)</i>
<a href="https://code.visualstudio.com/Download#" rel="external">VSCode-win32-x64-1.94.2.zip</a>       <i>(131 MB)</i>
</pre>
</dd></dl>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/October 2024* [**&#9650;**](#top)  <!-- October 2023 -->
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[ada_examples]: https://github.com/michelou/ada-examples#top
[akka_examples]: https://github.com/michelou/akka-examples#top
[cobol_examples]: https://github.com/michelou/cobol-examples#top
[conemu_downloads]: https://github.com/Maximus5/ConEmu/releases
[conemu_relnotes]: https://conemu.github.io/blog/2023/07/24/Build-230724.html
[cpp_examples]: https://github.com/michelou/cpp-examples#top
[dafny]: https://dafny.org/
[dafny_downloads]: https://github.com/dafny-lang/dafny/releases
[dafny_relnotes]: https://github.com/dafny-lang/dafny/releases/tag/v4.8.1
[dart_examples]: https://github.com/michelou/dart-examples#top
[deno_examples]: https://github.com/michelou/deno-examples#top
[docker_examples]: https://github.com/michelou/docker-examples#top
[dotnet_sdk_downloads]: https://dotnet.microsoft.com/en-us/download/dotnet/6.0
[dotnet_sdk_relnotes]: https://github.com/dotnet/core/blob/main/release-notes/6.0/6.0.33/6.0.33.md
[flix_examples]: https://github.com/michelou/flix-examples#top
[git_cli]: https://git-scm.com/docs/git
[git_downloads]: https://git-scm.com/download/win
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.46.1.txt
[github_markdown]: https://github.github.com/gfm/
[golang_examples]: https://github.com/michelou/golang-examples#top
[gpcp_jvm_releases]: https://github.com/pahihu/gpcp-JVM/releases
[graalvm_examples]: https://github.com/michelou/graalvm-examples
[haskell_examples]: https://github.com/michelou/haskell-examples
[ide-vscode_relnotes]: https://github.com/dafny-lang/ide-vscode/releases
[kafka_examples]: https://github.com/michelou/kafka-examples#top
[kotlin_examples]: https://github.com/michelou/kotlin-examples#top
[linux_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[llvm_examples]: https://github.com/michelou/llvm-examples#top
[m2_examples]: https://github.com/michelou/m2-examples#top
[make_cli]: https://www.gnu.org/software/make/manual/html_node/Options-Summary.html
[man1_awk]: https://www.linux.org/docs/man1/awk.html
[man1_diff]: https://www.linux.org/docs/man1/diff.html
[man1_file]: https://www.linux.org/docs/man1/file.html
[man1_grep]: https://www.linux.org/docs/man1/grep.html
[man1_more]: https://www.linux.org/docs/man1/more.html
[man1_mv]: https://www.linux.org/docs/man1/mv.html
[man1_rmdir]: https://www.linux.org/docs/man1/rmdir.html
[man1_sed]: https://www.linux.org/docs/man1/sed.html
[man1_wc]: https://www.linux.org/docs/man1/wc.html
[msys2_changelog]: https://github.com/msys2/setup-msys2/blob/main/CHANGELOG.md
[msys2_downloads]: http://repo.msys2.org/distrib/x86_64/
[nodejs_examples]: https://github.com/michelou/nodejs-examples#top
[rust_examples]: https://github.com/michelou/rust-examples#top
[scala3_examples]: https://github.com/michelou/dotty-examples#top
[sh_cli]: https://man7.org/linux/man-pages/man1/sh.1p.html
[spark_examples]: https://github.com/michelou/spark-examples#top
[spring_examples]: https://github.com/michelou/spring-examples#top
[trufflesqueak_examples]: https://github.com/michelou/trufflesqueak-examples
[unix_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[vscode_downloads]: https://code.visualstudio.com/#alt-downloads
[vscode_relnotes]: https://code.visualstudio.com/updates/
[windows_installer]: https://docs.microsoft.com/en-us/windows/win32/msi/windows-installer-portal
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst
[wix_examples]: https://github.com/michelou/wix-examples#top
[zig_examples]: https://github.com/michelou/zig-examples#top
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
