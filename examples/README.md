# <span id="top">Dafny Examples</span> <span style="font-size:90%;">[⬆](../README.md#top)</span>

<table style="font-family:Helvetica,Arial;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:25%;"><a href="https://dafny.org/" rel="external"><img src="../docs/images/dafny-logo.jpg" width="100" alt="Dafny project"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">Directory <a href="."><strong><code>examples\</code></strong></a> contains <a href="https://dafny.org/" rel="external" title="Dafny">Dafny</a> code examples coming from various websites - mostly from the <a href="https://dafny.org/" rel="external" title="Dafny">Dafny</a> project.<br/>
  It also includes build scripts (<a href="https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_02_01.html" rel="external">Bash scripts</a>, <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting" rel="external">batch files</a>, <a href="https://makefiletutorial.com/" rel="external">Make scripts</a>) for experimenting with <a href="https://dafny.org/" rel="external">Dafny</a> on a Windows machine.</td>
  </tr>
</table>

## <span id="fib">`Fibonacci` Example</span>

This example has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree" rel="external">tree</a> /f /a . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /v /b [A-Z]</b>
|   <a href="./Fibonacci/build.bat">build.bat</a>
|   <a href="./Fibonacci/build.sh">build.sh</a>
\---<b>src</b>
        <a href="./Fibonacci/src/Fib.dfy">Fib.dfy</a>
</pre>

Command [**`build.bat`**](./Fibonacci/build.bat)`-verbose clean run` generates and executes the [Dafny] program `target\Fib.exe` :

<pre style="font-size:80%;">
<b>&gt; <a href="./Fibonacci/build.bat">build</a> -verbose clean run</b>
Delete directory "target"
Build Dafny program "target\Fib.exe"

Dafny program verifier finished with 3 verified, 0 errors
Execute Dafny program "target\Fib.exe"
fib(10)=55
</pre>

> **Note**: The Dafny command can generate several targets besides the native executable presented above. We simply specify the command option `--target <name>` :
>
> |  Name  | Target&nbsp;language | `PATH`&nbsp;at build time |
> |:-------|:-----------|:------------|
> | `cs`   | [C#][target_csharp] | |
> | `js`   | [JavaScript][target_javascript] | |
> | `go`   | [Go][target_golang] | + `%GOROOT%\bin;%GOBIN%` <sup id="anchor_02">[2](#footnote_02)</sup> |
> | `java` | [Java][target_java] | + `%JAVA_HOME%\bin` |
> | `py`   | [Python][target_python] | |
> | `cpp`  | [C++][target_cpp] | |
> | `lib`  | [Dafny][target_dafny] Library (.doo) | |
> | `rs`   | [Rust][target_rust] | |
> | `dfy`  | [ResolvedDesugaredExecutableDafny][target_desugared] | |

Command [`build.bat`](./Fibonacci/build.bat) with option `-target:java` compiles and generates the file `target\Fib.jar` :

<pre style="font-size:80%;">
<b>&gt; <a href="./Fibonacci/build.bat">build</a> -debug -target:java clean run</b>
[build] Options    : _TARGET=java _VERBOSE=0
[build] Subcommands:  clean compile run
[build] Variables  : "CARGO_HOME=C:\Users\michelou\.cargo"
[build] Variables  : "DAFNY_HOME=C:\opt\dafny"
[build] Variables  : "GIT_HOME=C:\opt\Git"
[build] Variables  : "JAVA_HOME=C:\opt\jdk-temurin-17.0.17_10"
[build] Variables  : "MSVS_HOME=C:\Program Files\Microsoft Visual Studio\2022\Community"
[build] rmdir /s /q "F:\examples\Fibonacci\target"
[build] "%DAFNY_HOME%\dafny.exe" build --target java --output  "F:\examples\Fibonacci\target\Fib.jar"  "F:\examples\Fibonacci\src\Fib.dfy"
Dafny program verifier finished with 3 verified, 0 errors
[build] "%JAVA_HOME%\bin\java.exe" -jar "F:\examples\Fibonacci\target\Fib.jar"
fib(10)=55
[build] _EXITCODE=0
</pre>

Command [`build.bat`](./Fibonacci/build.bat) with option `-target:go` <sup id="anchor_01">[1](#footnote_01)</sup> compiles and generates the file `target\Fib.exe` :

<pre style="font-size:80%;">
<b>&gt; <a href="./Fibonacci/build.bat">build</a> -verbose -target:go clean run</b>
Build Dafny program "target\Fib.exe" with "go" target

Dafny program verifier finished with 3 verified, 0 errors
Execute Dafny program "target\Fib.exe"
fib(10)=55
</pre>

> **:mag_right:** Let's compare the binary files generated with target options `native`, `go` and `rs` :
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/dir" rel="external">dir</a> *.exe| <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /e .exe</b>
> 01/11/2025  08:45 PM         2,553,856 Fib_go.exe
> 01/11/2025  08:45 PM           151,040 Fib_native.exe
> 01/12/2025  01:10 AM           359,936 Fib_rust.exe
> </pre>
> Go
> <pre style="font-size:80%;">
> <b>&gt; <a href="">pelook.exe</a> Fib_go.exe | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /c:signature /c:linkver /c:toolset /c:modules:</b>
> signature/type:       PE64 EXE image for amd64
> linkver:              3.0
> import modules:       kernel32.dll
> delay-import modules: &lt;none>
> </pre>
> Native
> <pre style="font-size:80%;">
> <b>&gt; <a href="">pelook.exe</a> Fib_native.exe | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /c:signature /c:linkver /c:toolset /c:modules:</b>
> signature/type:       PE64 EXE image for amd64
> linkver:              Microsoft LINK 14.29
> detected toolset(s):  Visual C++ 9.0 2008 SP1 (build 30729) <--COMPILER(s)
> import modules:       KERNEL32.dll, USER32.dll, SHELL32.dll, ADVAPI32.dll,
>                       api-ms-win-crt-runtime-l1-1-0.dll,
>                       [...]
>                       api-ms-win-crt-time-l1-1-0.dll
> delay-import modules: &lt;none>
> </pre>
> Rust
> <pre style="font-size:80%;">
> <b>&gt; <a href="">pelook.exe</a> Fib_rust.exe | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /c:signature /c:linkver /c:toolset /c:modules:</b>
> signature/type:       PE64 EXE image for amd64
> linkver:              Microsoft LINK 14.41
> detected toolset(s):  Visual C++ 9.0 2008 SP1 (build 30729) <--COMPILER(s)
> import modules:       api-ms-win-core-synch-l1-2-0.dll, KERNEL32.dll,
>                       ntdll.dll, VCRUNTIME140.dll, api-ms-win-crt-math-l1-1-0.dll,
>                       [...]
>                       api-ms-win-crt-heap-l1-1-0.dll
> delay-import modules: &lt;none>
> </pre>

<!--================================================================-->
## <span id="getting_started">`GettingStarted` Example</span>

This example has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree" rel="external">tree</a> /f /a . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /v /b [A-Z]</b>
|   <a href="./GettingStarted/00download.txt">00download.txt</a>
|   <a href="./GettingStarted/build.bat">build.bat</a>
|   <a href="./GettingStarted/build.sh">build.sh</a>
\---<b>src</b>
        <a href="./GettingStarted/src/GettingStarted.dfy">GettingStarted.dfy</a>
</pre>

Command [**`build.bat`**](./GettingStarted/build.bat)`-verbose clean run` generates and executes the [Dafny] program `target\GettingStarted.exe`:

<pre style="font-size:80%;">
<b>&gt; <a href="./GettingStarted/build.bat">build</a> -verbose clean run</b>
Delete directory "target"
Build Dafny program "target\GettingStarted.exe"

Dafny program verifier finished with 2 verified, 0 errors
Execute Dafny program "target\GettingStarted.exe"
GettingStarted: Abs(-3)=3
</pre>

<!--=======================================================================-->

## <span id="footnotes">Footnotes</span> [**&#x25B4;**](#top)

<span id="footnote_01">[1]</span> ***Missing* <code>goimports</code> *command*** [↩](#anchor_01)

<dl><dd>
<pre style="font-size:80%;">
<b>&gt; %GOROOT%\bin\<a href="https://pkg.go.dev/cmd/go" rel="external">go</a> install golang.org/x/tools/cmd/goimports@latest</b>
go: downloading golang.org/x/tools v0.38.0
go: downloading golang.org/x/mod v0.29.0
go: downloading golang.org/x/sync v0.17.0
</pre>

<pre style="font-size:80%;">
<b>&gt; %GOROOT%\bin\go.exe version -m %GOBIN%\goimports.exe</b>
%GOBIN%\goimports.exe: go1.25.3
        path    golang.org/x/tools/cmd/goimports
        mod     golang.org/x/tools      v0.38.0 h1:Hx2Xv8hI...ibYI/IQ=
        dep     golang.org/x/mod        v0.29.0 h1:D4nJWe9z...59z1pH4=
        dep     golang.org/x/sync       v0.17.0 h1:l60nONMj...k2oT9Ug=
        dep     golang.org/x/sys        v0.37.0 h1:fdNQudmx...1goi9kQ=
        build   -buildmode=exe
        build   -compiler=gc
        build   DefaultGODEBUG=asynctimerchan=1,gotypesalias=1,[...]
        build   CGO_ENABLED=1
        build   CGO_CFLAGS=
        build   CGO_CPPFLAGS=
        build   CGO_CXXFLAGS=
        build   CGO_LDFLAGS=
        build   GOARCH=amd64
        build   GOOS=windows
        build   GOAMD64=v1
</pre>
</dd></dl>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/November 2025* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[dafny]: https://dafny.org/
[target_cpp]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/Cplusplus
[target_csharp]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/CSharp
[target_dafny]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/Dafny
[target_desugared]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/ResolvedDesugaredExecutableDafny
[target_golang]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/GoLang
[target_java]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/Java
[target_javascript]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/JavaScript
[target_python]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/Python
[target_rust]: https://github.com/dafny-lang/dafny/tree/master/Source/DafnyCore/Backends/Rust
