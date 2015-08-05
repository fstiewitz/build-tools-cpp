## 3.1.0 - Ask before execution
* Added 3 new commands (`first/second/third-command-ask`, `ctrl+l o/i/u`) that let you change the command before executing it (e.g. to enter `make` targets)
* Fix small visual bug in modal panels

## 3.0.0 - Profiles
* <b> build-tools-cpp is now build-tools
* Same disclaimer as v2.0.0: This is a large update. I've added more jasmine specs but I can never be sure that everything works. If you encounter any strange package behaviour or bugs, please let me know.
</b>
* Key bindings are now called `First/Second/Third Command` and not `Make/Configure/PreConfigure Command`
* Added highlighting profiles for Java, Python and apm test.
* Linter plugin now supports stack traces.
* New option to hide console output on success.
* New option to show all projects in Build Tools Settings
* Added scroll bars to modal panels (if necessary)
* Small UI improvements
* Bug fixes

## 2.0.5 - Linter 1.0.0
* Use new [Linter](https://github.com/AtomLinter/Linter) API
* <b>Update to linter@v1.0.0 or linting won't work</b>

## 2.0.0 - Per-project settings, Part 2
* <b> Pre v2.0.0 settings will be erased. Sorry for the inconvenience.
* This is a large update. I've added jasmine specs with 84 tests and 869 assertions but I can never be sure that everything works. If you encounter any strange package behaviour or bugs, please let me know. </b>
* Project settings are now saved in `~/.atom/build-tools-cpp.projects` or your OS equivalent.
* Support for multiple root folders because the settings are not stored via Atom's serializer anymore.
* Settings are now modified via a settings page similar to Atom's settings-view.
* Build folder, shell execution and wildcards are now set per-command.
* File marking, highlighting and linting are now set per-output-stream per-command.
* Dependencies allow you to chain commands, e.g. the build command of your executable first executes the build command of your required library.
* Press `ctrl-l ctrl-,` to open the new settings page.

## 1.2.3 - Ninja support
* Some build systems and compilers do not use stderr to display error messages ( e.g. Ninja ). This update adds an option to the package's global settings menu that enables error highlighting in stdout. This option is disabled by default and should only be enabled when necessary.

## 1.2.0 - Additional commands
* Press `ctrl-l ctrl-l` or execute `build-tools-cpp:show-commands` to add,edit,remove and execute additional commands
* They work like the `Make`, `Configure` and `Pre-configure` commands, except that they do not have a keybinding

![feature](https://cloud.githubusercontent.com/assets/7817714/6352478/439f1004-bc43-11e4-9549-9f315cd7b2eb.png)

## 1.1.0 - Auto-save
* Added option to automatically save all files before building

## 1.0.0 - Per-project settings
* Moved `Build Folder` and build commands from atom's settings panel to a settings panel, which can be accessed via `build-tools-cpp:settings` or by clicking the arrow next to the package view's close button
* You can have multiple atom windows with different build settings open at the same time
* Reduced startup time ( 400ms to 4ms )

## 0.8.0 - Linter
* Install [Linter](https://atom.io/packages/linter) to use inline error highlighting

## 0.7.0 - Absolute build path
* Bugfix: `Uncaught TypeError: Arguments to path.join must be strings`
* `Build Folder` now allows an absolute path
* Use path of currently opened file if project path is not available

## 0.6.0 - Per-project settings
* Settings now use serialization to allow users to have different settings for different projects
* After you updated this package you may have to set the settings for your project(s) again to initialize the serialization
* Opening multiple projects at the same time causes problems ( so don't do it )
* New projects have default build settings

## 0.5.0 - Wildcards
* See [README.md](README.md) for details

## 0.4.0 - Use atom's styleguide
* Improve file path highlighting

## 0.3.0 - Refactor code, Clang and specs
* Refactor code for better readability
* Add clang support ( at least with `-fno-diagnostics-fixit-info`)
* Add specs ( at least for some functions )

## 0.2.0 - Error messages and improved README.md
* Add error messages when build files (e.g. `Makefile`, `CMakeLists.txt`, `configure.ac`) do not exist
* Add syntax rules to [README.md](README.md)

## 0.1.0 - First Release
See [README.md](README.md) for details
