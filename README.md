build-tools-cpp
===============
[![Build Status](https://travis-ci.org/deprint/build-tools-cpp.svg?branch=settings-view)](https://travis-ci.org/deprint/build-tools-cpp) [![Dependency Status](https://david-dm.org/deprint/build-tools-cpp/settings-view.svg)](https://david-dm.org/deprint/build-tools-cpp/settings-view) [![devDependency Status](https://david-dm.org/deprint/build-tools-cpp/settings-view/dev-status.svg)](https://david-dm.org/deprint/build-tools-cpp/settings-view#info=devDependencies) [![apm](https://img.shields.io/apm/dm/build-tools-cpp.svg)](https://github.com/deprint/build-tools-cpp) [![apm](https://img.shields.io/apm/v/build-tools-cpp.svg)](https://github.com/deprint/build-tools-cpp)

### Build your projects in atom
![Error highlighting](/home/fabian/console.png)

![Settings](/home/fabian/settings.png)

## Features
* Execute build commands in Atom
* Set up different commands for different projects
* Chain commands and projects with dependenies
* Errors are highlighted both inside the console and in-line with [Linter](https://github.com/AtomLinter/Linter)
* File coordinates are highlighted and can be opened

## Keys
* `ctrl+l ctrl+u/i/o` for executing the 1st/2nd/3rd command of a project
* `ctrl+l ctrl+l` to list all commands of a project
* `ctrl+l ctrl+,` to open per-project settings

## Settings
### Commands
![Command](/home/fabian/command.png)

### Dependencies
![Dependency](/home/fabian/dependency.png)
* Dependencies are executed in descending order
* <b>Commands are not executed twice
* Build fails if one of the dependencies returns a non-zero exit code

### Key bindings
![Key bindings](/home/fabian/key_bindings.png)
* Useful if you have multiple projects
* By default, the commands are from the currently active project
* If you have a multi-project setup with dependencies and want to build everything you can set up the key bindings of each project to execute the `Compile` command of the top-level project. If you now execute the key binding it will execute the `Compile` command of the top-level project and thanks to dependencies all lower-level projects ( e.g. your libraries ) will be built as well.

## Roadmap
* Project templates
* Custom regular expressions for other compilers
* Service provider for other packages
* Bug fixes, UI improvements, etc.

## Contributing
* Let me know if you encounter any bugs.
* Feature requests are always welcome.
