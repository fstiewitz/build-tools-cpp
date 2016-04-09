## 4.4.0 - Stream Modifiers

* New service: `stream-modifier`.
* New modules: __Highlight All__, __Remove ANSI Codes__, __Highlighting Profiles__ and __Custom Regular Expressions__.
* Your commands will automatically migrate to the new format.
* Users can configure multiple stream modifiers per output stream.
* Stream modifiers add support for recursive build systems (with relative file paths).
* Added options related to output stream mapping:
  * Disable both output streams
  * Disable standard output stream
  * Disable standard error stream
  * Redirect standard output into standard error
  * Redirect standard error into standard output
  * Enable both output streams
  * Both redirect settings for `pty.js`
* `SIGKILL` processes if they don't react to `SIGINT`.

## 4.3.0 - pty.js

* Added option to execute command through a pseudo terminal (using [pty.js](https://www.npmjs.com/package/pty.js)), which fixes buffering issues when using stdin.
* Fixes display issues in console pane.

## 4.1.0 - Better I/O

* Output modules now have access to stdin (for users: You can now interact with your spawned process)
* Added options to remove or highlight ANSI Color Codes:
  * ANSI Color Codes are hidden when highlighting is set to anything other than "No highlighting"
  * ANSI Color Codes are displayed (not highlighted, you'll see the actual escape code) by default when "No highlighting" is enabled
  * ANSI Color Codes include 8 text colors, 8 background colors, underline, italic and bold. Supporting ALL ANSI Codes is beyond the scope of this package.

To use the new features you have to reconfigure your commands.

## 4.0.0 - Modules
__Major changes for the user:__

* __Support for v3.x's global configuration file has been dropped__
* __Commands now have to be configured in local configuration files (`.build-tools.cson`)__
* __Local commands pre4.0 will migrate if you open them for the first time__
* __Global commands can be imported if you create/open a local config file in a project folder with configured global commands by clicking the `Migrate old commands` button__
* __Dependencies pre4.0 have to be reconfigured for each command individually__

__Major changes for package developers: This update introduces 5 services that package developers can use in their packages to ...__

* __... execute commands (Input module)__
* __... provide commands (Provider modules)__
* __... modify command parameters (Modifier modules)__
* __... highlight the output of commands (Profile modules)__
* __... get the output of commands (Output modules)__

__Refer to the [wiki](https://github.com/deprint/build-tools-cpp/wiki) for details.__

* Allow parallel execution of commands
* Dependency settings are now stored per-command
* Added modifier module for environment variables
* Shell command is now stored per-command
* Added output module to display output in an undefined text editor
* Added output module to write output to a file
* Console panel now has tabs for each command
* Added provider module for external configuration files
* Added highlighting option for custom regular expressions
* User Interface has been adjusted to better reflect the internal structure of this package

## 3.7.1 - Fix outdated jquery calls

## 3.7.0 - Service API: Profiles
* This update introduces a service interface for other packages to add their own [highlighting profiles](https://github.com/deprint/build-tools-cpp/wiki/Service-API:-Profiles)

## 3.6.0 - UI for local configuration files
* Added UI for local configuration files

## 3.5.0 - New Profile: Modelsim
* Added new profile: Modelsim
* Created github wiki page for developing your own highlighting profiles (service provider and UI for simple profiles are coming soon)
* Fix two uncaught exceptions in settings view

## 3.4.0 - Local configuration files
* If you execute a command, the package will climb up the file tree and if it finds a `.build-tools.cson` it will use the configuration of said file in favor of any global project settings.
* Limitations:
  1. No UI for editing local config files
  2. No local dependencies
* Added snippets for editing local config files: `btp<TAB>btc<TAB>` to get started
* Example config:
``` coffee
  'commands': [
    {
      'name': 'Test'
      'command': 'echo Hello World!'
      'wd': '.' #Working directory. Default: .
      'shell': false #Execute in shell
      'wildcards': false #Replace wildcards
      'save_all': false #Save all
      'close_success': false #Close console on success
      'stdout':
        'file': false #Highlight files
        #nh: No highlighting
        #ha: Highlight all
        #ht: Highlight tags
        #hc: Highlighting profile (requires 'profile')
        'highlighting': 'nh'
        #gcc_clang: GCC/Clang
        #apm_test: apm test (Jasmine specs)
        #java: Java
        #python: Python
        #'profile': 'gcc_clang' #Uncomment if 'highlighting' is 'hc'
        'lint': false #Lint errors/warnings
      'stderr':
        'file': false
        'highlighting': 'hc'
        'lint': false
      #Backwards compatibility with older command versions (don't change it)
      'version': 2
    }
  ]
```

## 3.3.0 - Advanced settings
* Options "Close on success" and "Save all" are now per-command
* Java: Highlight "required" and other tags

## 3.2.3 - Command Pane
* The command dialog pane is getting a little too large (will get even larger next week), so I moved it into the project settings view

## 3.2.0 - Open output & UI improvements
* There is a new icon in the top right corner of the console pane that, when clicked on, opens a new untitled editor with the content of the console output
* UI improvements:
  * Added a progress bar to the console pane (most useful when working with dependencies)
  * Import and dependency panel now have "Show all projects" checkboxes (disabled by default)
  * Settings view and all panels have been modified to look more like Atom's settings view

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
