# Inweb 7.1.0

v7.1.0-beta+1A96 'Escape to Danger' (28 April 2022)

## About Inweb

Inweb offers a modern approach to literate programming. Unlike the original
LP tools of the late 1970s, led by Donald Knuth, or of the 1990s revival,
Inweb aims to serve programmers in the Github age. It scales to much larger
programs than CWEB, and since 2004 has been the tool used by the
[Inform programming language project](https://github.com/ganelson/inform),
where it manages a 300,000-line code base.

Literate programming is a methodology created by Donald Knuth in the late
1970s. A literate program, or "web", is written as a narrative intended to
be readable by humans as well as by other programs. Inweb is itself written as
a web, and its human-readable form is a [companion website to this one](https://ganelson.github.io/inweb/index.html).

For the Inweb manual, see [&#9733;&nbsp;inweb/Preliminaries](https://ganelson.github.io/inweb/inweb/M-iti).

__Disclaimer__. Because this is a private repository (until the next public
release of Inform, when it will open), its GitHub pages server cannot be
enabled yet. As a result links marked &#9733; lead only to raw HTML
source, not to served web pages. They can in the mean time be browsed offline
as static HTML files stored in "docs".

## Licence and copyright

Except as noted, copyright in material in this repository (the "Package") is
held by Graham Nelson (the "Author"), who retains copyright so that there is
a single point of reference. As from the first date of this repository
becoming public, 28 April 2022, the Package is placed under the
[Artistic License 2.0](https://opensource.org/licenses/Artistic-2.0).
This is a highly permissive licence, used by Perl among other notable projects,
recognised by the Open Source Initiative as open and by the Free Software
Foundation as free in both senses.

A condition of any pull-request being made (i.e., to make suggested amendments
to this software) is that, if the request is accepted, copyright on any contribution
made by it immediately transfers to the project's copyright-holder, Graham Nelson.
This is in order that there can be clear ownership.

## Build Instructions

Inweb is intentionally self-sufficient, with no dependencies on any other
software beyond a modern C compiler. However, it does in a sense depend on
itself: because Inweb is itself a web, you need Inweb to compile Inweb.
Getting around that circularity means that the initial setup takes a few steps.

Make a directory in which to work: let's call this "work". Then:

* Change the current directory to this: "cd work"
* Clone Inweb: "git clone https://github.com/ganelson/inweb.git"
* Run **one of the following commands**. Unix is for any generic version of Unix,
non-Linux, non-MacOS: Solaris, for example. Android support is currently disabled,
though only because its build settings are currently missing from the inweb
distribution. The older macos32 platform won't build with the MacOS SDK from
10.14 onwards, and in any case 32-bit executables won't run from 10.15 onwards:
so use the default macos unless you need to build for an old version of MacOS.
(Settings for making Apple Silicon and universal binaries on MacOS will follow,
but are not yet ready.)
	* "bash inweb/scripts/first.sh linux"
	* "bash inweb/scripts/first.sh macos"
	* "bash inweb/scripts/first.sh macos32"
	* "bash inweb/scripts/first.sh unix"
	* "bash inweb/scripts/first.sh windows"
* Test that all is well: "inweb/Tangled/inweb -help"

You should now have a working copy of Inweb, with its own makefile tailored
to your platform now in place (at inweb/inweb.mk). To build inweb again, e.g.
after editing inweb's source code, do not run the shell script first.sh again.
Instead, you must use: "make -f inweb/inweb.mk"

If you wish to tweak the makefile, do not edit it directly. Instead,
edit inweb/scripts/inweb.mkscript and inweb/Materials/platforms/PLATFORM.mkscript,
where PLATFORM is your choice as above (e.g., 'macos'). Then run "make -f inweb/inweb.mk makers"
to rebuild all these makefiles with your changes incorporated; and then run
the shell script "inweb/scripts/first.sh" again.

## Reporting Issues

The bug tracker for Inweb is powered by Jira and hosted
[at the Atlassian website](https://inform7.atlassian.net/jira/software/c/projects/INWEB/issues).
(Note that Inform, Inweb and Intest are three different projects in Jira: please
do not report Inweb issues on the Inform bug tracker or vice versa.)

The curator of the bug tracker is Brian Rushton, and the administrator is
Hugo Labrande.

## Pull Requests and Adding Features

Substantially different versions of Inweb have been open-source before, but this
version is essentially a fresh reimplementation with a different design. It is
the curse of literate-programming tools that they serve only their own authors,
that is, few LP tools please users other than the creators: thus, only Knuth
really uses CWEB, for example. But perhaps that will change. It's time for LP
to be tried again, and Inweb may be a start.

For the moment, however, Inweb's future direction remains in the hands of the
original author. It needs to be reliable and to keep the Inform and Intest projects
working, as well as itself.

At some point a more formal process may emerge, but for now community discussion
of possible features is best kept to the IF forum. In particular, please do not
use the bug trackers to propose new features.

Pull requests adding functionality or making any significant changes are therefore
not likely to be accepted from non-members of the wider Inform team without prior
agreement, unless they are clear-cut bug fixes or corrections of typos, broken
links, or similar. See also the note about copyright above.

The Inweb licence is highly permissive, and forks which develop in quite different
ways are entirely within the rules. (But one of the few requirements of the
Artistic Licence is that such forks be given a name which is not simply "Inweb",
to avoid confusion.)

## Also Included

Inweb contains a substantial library of code shared by a number of other
programs, such as the [Intest testing tool](https://github.com/ganelson/intest)
and the [Inform compiler and related tools](https://github.com/ganelson/inform).

This library is called "Foundation", and has its own web
here: [&#9733;&nbsp;foundation-module](https://ganelson.github.io/inweb/foundation-module/index.html).

A small executable for running unit tests against Foundation is also included:
[&#9733;&nbsp;foundation-test](https://ganelson.github.io/inweb/foundation-test/index.html).

## Testing Inweb

If you have also built Intest as "work/intest", then you can try these:

* intest/Tangled/intest inweb all
* intest/Tangled/intest inweb/foundation-test all

### Colophon

This README.mk file was generated automatically by Inweb, and should not
be edited. To make changes, edit inweb.rmscript and re-generate.

