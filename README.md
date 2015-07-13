build-tools (prev. build-tools-cpp)
===============
[![Build Status](https://travis-ci.org/deprint/build-tools-cpp.svg)](https://travis-ci.org/deprint/build-tools-cpp) [![Dependency Status](https://david-dm.org/deprint/build-tools-cpp.svg)](https://david-dm.org/deprint/build-tools-cpp) [![apm](https://img.shields.io/apm/dm/build-tools-cpp.svg)](https://github.com/deprint/build-tools-cpp) [![apm](https://img.shields.io/apm/v/build-tools-cpp.svg)](https://github.com/deprint/build-tools-cpp)

### Build your projects in atom
![Error highlighting](https://cloud.githubusercontent.com/assets/7817714/8662380/3741bdc2-29bf-11e5-9456-f0fe9d0a33cb.png)

![Settings](https://cloud.githubusercontent.com/assets/7817714/8662384/3e7c78fc-29bf-11e5-9efc-64bce98deea7.png)

## Features
* Execute programs/compilers in Atom
* Set up different commands for different projects
* Chain commands and projects with dependenies
* Errors are highlighted both inside the console and in-line with [Linter](https://github.com/AtomLinter/Linter)
* File coordinates are highlighted and can be opened
* Can highlight <b>GCC, Clang, Python, Java and apm test</b>

## Keys
* `ctrl+l ctrl+u/i/o` for executing the 1st/2nd/3rd command of a project
* `ctrl+l ctrl+l` to list all commands of a project
* `ctrl+l ctrl+,` to open per-project settings
* `ctrl+l ctrl+s` to show console output

## Settings
### Commands
![Command](https://cloud.githubusercontent.com/assets/7817714/8662378/329e3232-29bf-11e5-873d-cd44bb89c286.png)

### Dependencies
![Dependency](https://cloud.githubusercontent.com/assets/7817714/8662383/39fdfca6-29bf-11e5-885a-a517807e5740.png)
* Dependencies are executed in descending order
* <b>Commands are not executed twice</b>
* Build fails if one of the dependencies returns a non-zero exit code

## Roadmap
* Project templates
* More highlighting profiles
* UI for creating simple highlighting profiles
* Service provider for other packages
* Bug fixes, UI improvements, etc.

## Contributing
* Let me know if you encounter any bugs.
* Feature requests are always welcome.
