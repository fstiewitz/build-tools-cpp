build-tools
===============
[![Travis](https://img.shields.io/travis/deprint/build-tools-cpp.svg?style=flat-square)](https://travis-ci.org/deprint/build-tools-cpp) [![AppVeyor](https://img.shields.io/appveyor/ci/deprint/build-tools-cpp.svg?style=flat-square)](https://ci.appveyor.com/project/deprint/build-tools-cpp) [![Dependency Status](https://david-dm.org/deprint/build-tools-cpp.svg?style=flat-square)](https://david-dm.org/deprint/build-tools-cpp) [![apm](https://img.shields.io/apm/dm/build-tools.svg?style=flat-square)](https://github.com/deprint/build-tools-cpp) [![apm](https://img.shields.io/apm/v/build-tools.svg?style=flat-square)](https://github.com/deprint/build-tools-cpp)

### Build your projects in atom
![Error highlighting](https://cloud.githubusercontent.com/assets/7817714/10537808/91cbf92c-73f4-11e5-9f0d-15348000c31f.png)

![Settings](https://cloud.githubusercontent.com/assets/7817714/10537701/e17d8b08-73f3-11e5-8b06-3981489b537d.gif)

## Features
* Execute programs/compilers in Atom
* Set up different commands for different projects
* Can highlight <b>GCC, Clang, Python, Java, Modelsim and apm test</b>
* Errors are highlighted both inside the console and in-line with [Linter](https://github.com/atom-community/linter)
* File coordinates are highlighted and can be opened
* Service interface for other package developers

## HowTo

1. Create a file called `.build-tools.cson` (preferably in your project's root folder)
2. Click `Add Provider`
3. Click `Add Custom Commands`
4. Click `Add Command`
5. Configure your command
6. Execute your command through one of the key bindings.

## Keys
* `ctrl+l ctrl+o/i/u` for executing the 1st/2nd/3rd command of a project
* `ctrl+l ctrl+l` to list all commands of a project
* `ctrl+l ctrl+s` to show console output
* `ctrl+l o/i/u` lets you view and change the command before executing it

## Service API
`build-tools` allows other packages to:
* add their own highlighting profiles
* execute their own commands
* provide their own commands
* modify command parameters
* get the command's output
* modify the command's output
* display their own content through `build-tools` tabbed console pane

Refer to the [wiki](https://github.com/deprint/build-tools-cpp/wiki) for details.

## Contributing
* Let me know if you encounter any bugs.
* Feature requests and critique are always welcome.
