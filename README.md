terminfo-parser
===============

This is a [Lua] parser for the [terminfo] source format used by
[ncurses]. It's intended to allow querying and transforming the
[database] via scripting, in a manner that's more flexible and
performant than using the command-line tools (i.e. [`infocmp`],
[`tput`], etc.).

**Note**: This library is not intended to replace the terminfo or curses
C APIs. Many control sequences in the database *must* be passed through
[`tparm(3)`] and/or [`tputs(3)`] before being sent to a terminal. Use
Lua bindings for the C APIs if you need a terminal control library.

Requirements
------------

* [Lua] 5.1+
* [LPeg] 1.0+

License
-------

Copyright (C) 2018-2019 Craig Barnes.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU [General Public License version 2], as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License version 2 for more details.


[Lua]: https://www.lua.org/
[LPeg]: http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html
[terminfo]: https://invisible-island.net/ncurses/man/terminfo.5.html
[database]: https://invisible-island.net/ncurses/#download_database
[ncurses]: https://invisible-island.net/ncurses/
[`tput`]: https://invisible-island.net/ncurses/man/tput.1.html
[`infocmp`]: https://invisible-island.net/ncurses/man/infocmp.1m.html
[`tparm(3)`]: https://invisible-island.net/ncurses/man/curs_terminfo.3x.html#h3-Formatting-Output
[`tputs(3)`]: https://invisible-island.net/ncurses/man/curs_terminfo.3x.html#h3-Output-Functions
[General Public License version 2]: https://www.gnu.org/licenses/gpl-2.0.html
