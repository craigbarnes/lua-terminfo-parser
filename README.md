terminfo-parser
===============

This is a [Lua] parser for the [terminfo] database source format used by
[ncurses]. It's intended to allow querying and transforming the database
via scripting, beyond what is possible or performant with the curses
command-line toolset (i.e. `tput`, `infocmp`, etc.).

Requirements
------------

* [Lua] 5.1+
* [LPeg] 1.0+

License
-------

Copyright (C) 2018 Craig Barnes.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU [General Public License version 2], as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License version 2 for more details.


[Lua]: https://www.lua.org/
[LPeg]: http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html
[terminfo]: https://invisible-island.net/ncurses/#download_database
[ncurses]: https://invisible-island.net/ncurses/
[General Public License version 2]: https://www.gnu.org/licenses/gpl-2.0.html
