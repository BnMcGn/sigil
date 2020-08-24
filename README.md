sigil
-----

Sigil is a Parenscript to Javascript command line compiler and REPL.

    What is Parenscript? (from https://common-lisp.net/project/parenscript/)

    Parenscript is a translator from an extended subset of Common Lisp
    to JavaScript. Parenscript code can run almost identically on both
    the browser (as JavaScript) and server (as Common Lisp).

    Parenscript code is treated the same way as Common Lisp code,
    making the full power of Lisp macros available for
    JavaScript. This provides a web development environment that is
    unmatched in its ability to reduce code duplication and provide
    advanced metaprogramming facilities to web developers.
    
    https://github.com/vsedach/Parenscript

    https://common-lisp.net/project/parenscript/reference.html

Usage
-----

    sigil [-i] [-I load-directory] [-C <upcase|downcase|preserve|invert>] [--eval <CL code>] 
    [--pseval <PS Code>] app.ps > app.js

Installation
------------

    $ npm install -g sigil-cli

This will automatically try to compile the executable which can then
be run with the `sigil` command. It requires from the system:

- [SBCL](http://sbcl.org/) (or some other Common Lisp implementation,
  but Sigil uses this by default)
- `make` for building the executable.
- `wget` for fetching dependencies.

Load
----

Sigil adds the 'load' command to Parenscript, so you can load macros
and other files during compilation, like (load "macros.ps"). Use -I to
specify the load paths to search.

Readtable Case
---------------

The readtable case can be set on the sigil command line with the -C 
switch. Valid values are upcase, downcase, preserve, and invert. All
items that follow will be read with the specified case. The -C switch
can be used multiple times on a single command.

Interactive REPL
----------------

Sigil comes with an interactive REPL (Read-Eval-Print-Loop) when
invoked with -i (or no arguments), allowing you to type and evaluate
Parenscript commands interactively.

License
-------

MIT

Author
------

Burton Samograd

Maintainer
----------

Ben McGunigle (bnmcgn at gmail.com)
