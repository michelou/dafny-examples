# <span id="top">Dafny Examples from Theo's Course</span> <span style="font-size:90%;">[⬆](../README.md#top)</span>

<table style="font-family:Helvetica,Arial;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:25%;"><a href="https://dafny.org/" rel="external"><img src="../docs/images/dafny-logo.jpg" width="100" alt="Dafny project"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">Directory <a href="."><strong><code>theo-examples\</code></strong></a> contains <a href="https://dafny.org/" rel="external" title="Dafny">Dafny</a> code examples coming from the <a href="https://www.engr.mun.ca/~theo/Courses/AlgCoCo/notes.html" rel="external" title="Dafny">Algorithms: Correctness and Complexity</a> course (Engi-5892).<br/>
  It also includes build scripts (<a href="https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_02_01.html" rel="external">Bash scripts</a>, <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting" rel="external">batch files</a>, <a href="https://makefiletutorial.com/" rel="external">Make scripts</a>) for experimenting with <a href="https://dafny.org/" rel="external">Dafny</a> on a Windows machine.</td>
  </tr>
</table>

## <span id="binarysearch">`BinarySearch` Example</span>

The code of this example is adapted from the [BinarySearches](https://www.engr.mun.ca/~theo/Courses/AlgCoCo/6892-downloads/binarySearches.dfy) example is presented in the <a href="https://www.engr.mun.ca/~theo/Courses/AlgCoCo/notes.html" rel="external" title="Dafny">Algorithms: Correctness and Complexity</a> course (Engi-5892).

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /f /a . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./BinarySearch/build.bat">build.bat</a>
|   <a href="./BinarySearch/build.sh">build.sh</a>
|   <a href="./BinarySearch/Makefile">Makefile</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>dafny</b>
                <a href="./BinarySearch/src/main/dafny/BinarySearch.dfy">BinarySearch.dfy</a>
</pre>

<!--===================================-->

## <span id="russianpeasant">`RussianPeasant` Example</span>

The code of this example is adapted from the [RussianPeasant](https://www.engr.mun.ca/~theo/Courses/AlgCoCo/6892-downloads/russianPeasantAlg.dfy) example is presented in the <a href="https://www.engr.mun.ca/~theo/Courses/AlgCoCo/notes.html" rel="external" title="Dafny">Algorithms: Correctness and Complexity</a> course (Engi-5892).

This example has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /f /a . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./RussianPeasant/00download.txt">00download.txt</a>
|   <a href="./RussianPeasant/build.bat">build.bat</a>
|   <a href="./RussianPeasant/build.sh">build.sh</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>dafny</b>
                <a href="./RussianPeasant/src/main/dafny/RussionPeasant.dfy">RussianPeasant.dfy</a>
</pre>

Command [**`build.bat`**](./RussianPeasant/build.bat)`-verbose clean run` generates and executes the [Dafny] program `target\RussianPeasant.exe` :

<pre style="font-size:80%;">
<b>&gt; <a href="./RussianPeasant/build.bat">build</a> -verbose clean run</b>
Build Dafny program "target\RussianPeasant.exe" with "native" target

Dafny program verifier finished with 7 verified, 0 errors
Execute Dafny program "target\RussianPeasant.exe"
mult(2, 3) = 6
power(2, 3) = 8
</pre>

Similarly command [**`make`**](./RussianPeasant/Makefile)`clean run` :

<pre style="font-size:80%;">
"/usr/bin/rm.exe" -rf "target"
[ -d "target" ] || "/usr/bin/mkdir.exe" -p "target"
"C:/opt/dafny/dafny.exe" build  --output target/RussianPeasant.exe src/main/dafny/RussianPeasant.dfy

Dafny program verifier finished with 7 verified, 0 errors
"target/RussianPeasant.exe"
mult(2, 3) = 6
power(2, 3) = 8
</pre>

<!--=======================================================================-->

## <span id="selectionsort">`SelectionSort` Example</span> [**&#x25B4;**](#top)

The code of this example is adapted from the [SelectionSort](https://www.engr.mun.ca/~theo/Courses/AlgCoCo/6892-downloads/SelectionSort.dfy) example is presented in the <a href="https://www.engr.mun.ca/~theo/Courses/AlgCoCo/notes.html" rel="external" title="Dafny">Algorithms: Correctness and Complexity</a> course (Engi-5892).

This example has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /f /a . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./SelectionSort/00download.txt">00download.txt</a>
|   <a href="./SelectionSort/build.bat">build.bat</a>
|   <a href="./SelectionSort/build.sh">build.sh</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>dafny</b>
                <a href="./SelectionSort/src/main/dafny/SelectionSort.dfy">SelectionSort.dfy</a>
</pre>

Command [**`build.bat`**](./SelectionSort/build.bat)`-verbose clean run` generates and executes the [Dafny] program `target\SelectionSort.exe` :

<pre style="font-size:80%;">
<b>&gt; <a href="./SelectionSort/build.bat">build</a> -verbose clean run</b>
Build Dafny program "target\SelectionSort.exe" with "native" target

Dafny program verifier finished with 10 verified, 0 errors
Execute Dafny program "target\SelectionSort.exe"
Before: [9, 4, 3, 6, 8]
After : [3, 4, 6, 8, 9]
</pre>

Similarly command [**`build.sh`**](./SelectionSort/build.sh)`-verbose clean run` :

<pre style="font-size:80%;">
<b>&gt; sh <a href="./SelectionSort/build.sh">build.sh</a> -verbose clean run</b>
Compile 1 Dafny source file to directory "target" with "native" target

Dafny program verifier finished with 11 verified, 0 errors
Execute program "target/SelectionSort.exe"
Before: [9, 4, 3, 6, 8]
After : [3, 4, 6, 8, 9]
</pre>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/June 2026* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[AlgCoCo]: https://www.engr.mun.ca/~theo/Courses/AlgCoCo/
[dafny]: https://dafny.org/
