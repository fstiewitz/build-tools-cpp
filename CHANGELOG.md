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
