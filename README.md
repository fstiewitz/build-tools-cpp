build-tools-cpp
===============

### Build your autotools / CMake / Makefile project in atom

![Error highlighting](https://cloud.githubusercontent.com/assets/7817714/3423149/34a97ec6-ff84-11e3-9237-8fe420bb1b90.png)

## Features
* Tested with Autotools, CMake and custom Makefiles
* Highlights errors and warnings of `gcc` and `g++`
* File paths can be opened with left click

<b>Error highlighting may not work with all compilers, but can be disabled.
</b>

## Limitations
* Error highlighting only works with `gcc` and `g++` v4.8+
* Error highlighting with `clang`/`clang++` only works properly with `-fno-diagnostics-fixit-info`

## How to
* Click `ctrl-l ctrl-u` to execute your `Pre-Configure command`
* Click `ctrl-l ctrl-i` to execute your `Configure command`
* Click `ctrl-l ctrl-o` to execute your `Build command`

## Example settings
| |Makefile | Autotools | CMake | Custom
---|---|---|---|---
Build folder | `.` | `.` | `build` | `.`
Build command | `make` | `make` | `make` | `g++ main.cpp -o hello_world`
Configure command | | `CXXFLAGS="-g -pg" ./configure` | `cmake ..` |
Pre-Configure command | | `autoreconf -ifv` | |

## Wildcards
You can use the following wildcards in your commands:

Wildcard | Description | Build folder | File path | Output
---|---|---|---
`%p` | Project path | Does not matter | |
`%c` | Currently opened file relative to your `Build Folder` | `.` | `main.cpp` | `main.cpp`
 | | `.` | `build/main.cpp` | `build/main.cpp`
 | | `build` | `main.cpp` | `../main.cpp`
 | | `build` | `build/main.cpp` | `main.cpp`
`%b` | Same as `%c` but without a file extension | `.` | `main.cpp` | `main`
 | | `.` | `build/main.cpp` | `build/main`
 | | `build` | `main.cpp` | `../main`
 | | `build` | `build/main.cpp` | `main`
`%n` | Name of the file ( no path, no extension ) | Does not matter | `main.cpp` | `main`
`%f` | Folder relative to your `Build Folder` | `.` | `main.cpp` | `.`
 | | `.` | `build/main.cpp` | `build`
 | | `build` | `main.cpp` | `..`
 | | `build` | `build/main.cpp` | `.`

To get absolute path names use `%gc`, `%gb` and `%gf`


## Syntax
Every command line has the following syntax:
`[Environment variables] Command [Arguments]`
### Environment variables
Syntax: `name="content"`
* No whitespaces between `name`,`=` and `"content"`
* `""` and `''` are optional

### Command
Syntax: `[folder]/program`
* `[folder]` is optional
* If program is not in `PATH` but in `Build folder` add `.` (e.g. `./configure`)
* Use `""` and `''` if your path contains whitespaces

### Arguments
* Arguments have the same syntax as if you write the command in a terminal
* The last argument of `cmake` has to be the build folder ( e.g. `cmake -Wno-dev ..`, not `cmake .. -Wno-dev`)
