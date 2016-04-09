{profile} = require './helper'

profile 'GCC/Clang', {
  stderr:
    pipeline: [
      {
        name: 'profile'
        config:
          profile: 'gcc_clang'
      }
    ]
}, 'stderr',
[
  'In file included from test/src/def.h:32:0, ',
  '                 from test/src/gen.h:31, ',
  '                 from test/src/gen.c:27: ',
  'should be traced too',
  '/usr/include/stdlib.h:483:13: note: expected ‘void *’ but argument is of type ‘const void *’',
  ' extern void free (void *__ptr) __THROW;',
  '             ^',
  'test/src/gen.c:126:6: error: implicit declaration of function ‘print_element’ [-Wimplicit-function-declaration]',
  '      print_element(input);',
  '      ^'
],
[
  {file: 'test/src/def.h'       , row: '32' , col: '0'      , type: 'trace'  , highlighting: 'note', message: 'expected ‘void *’ but argument is of type ‘const void *’'},
  {file: 'test/src/gen.h'       , row: '31' , col: undefined, type: 'trace'  , highlighting: 'note', message: 'expected ‘void *’ but argument is of type ‘const void *’'},
  {file: 'test/src/gen.c'       , row: '27' , col: undefined, type: 'trace'  , highlighting: 'note', message: 'expected ‘void *’ but argument is of type ‘const void *’'},
  {file: '/usr/include/stdlib.h', row: '483', col: '13'     , type: 'note'   ,                       message: 'expected ‘void *’ but argument is of type ‘const void *’'},
  {file: 'test/src/gen.c'       , row: '126', col: '6'      , type: 'error'  ,                       message: 'implicit declaration of function ‘print_element’ [-Wimplicit-function-declaration]'},
],
[
  [{file: 'test/src/def.h'       , row: '32' , col: '0'      , start: 22, end: 40}],
  [{file: 'test/src/gen.h'       , row: '31' , col: undefined, start: 22, end: 38}],
  [{file: 'test/src/gen.c'       , row: '27' , col: undefined, start: 22, end: 38}],
  [],
  [{file: '/usr/include/stdlib.h', row: '483', col: '13'     , start: 0 , end: 27}],
  [],
  [],
  [{file: 'test/src/gen.c'       , row: '126', col: '6'      , start: 0 , end: 19}],
  [],
  []
]

profile 'apm test', {
  stderr:
    pipeline: [
      {
        name: 'profile'
        config:
          profile: 'apm_test'
      }
    ]
}, 'stderr',
[
  '.................................................FF...............................................'
  ''
  'Profiles'
  '  apm test'
  '    on :: in with multi line match'
  '      it correctly sets warnings'
  '        Expected undefined to be \'test/src/def.h\'.'
  '          Error: Expected undefined to be \'test/src/def.h\'.'
  '          at /home/fabian/.atom/packages/build-tools-cpp/spec/profile-spec.coffee:183:32'
  '          at [object Object].<anonymous> (/home/fabian/.atom/packages/build-tools-cpp/spec/profile-spec.coffee:340:15)'
  '          at _fulfilled (/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js:794:54)'
  '          at self.promiseDispatch.done (/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js:823:30)'
  '          at Promise.promise.promiseDispatch (/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js:756:13)'
  '          at /home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js:564:44'
  '          at flush (/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js:110:17)'
  '          at process._tickCallback (node.js:357:13)'
  'RegExp tests'
  '  Simple regex'
  '    it returns the correct match'
  '      TypeError: Cannot read property \'groups\' of undefined (spec/regex-spec.coffee:16:18)'
],
[
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.'    , file: '/home/fabian/.atom/packages/build-tools-cpp/spec/profile-spec.coffee'    , row: '340', col: '15'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.'    , file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '794', col: '54'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.'    , file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '823', col: '30'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.'    , file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '756', col: '13'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.'    , file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '564', col: '44'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.'    , file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '110', col: '17'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.'    , file: 'node.js'                                                                 , row: '357', col: '13'},
  {type: 'error', message: 'Error: Expected undefined to be \'test/src/def.h\'.'    , file: '/home/fabian/.atom/packages/build-tools-cpp/spec/profile-spec.coffee'    , row: '183', col: '32'}
  {type: 'error', message: 'TypeError: Cannot read property \'groups\' of undefined', file: 'spec/regex-spec.coffee'                                                  , row: '16' , col: '18'}
],
[
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [{file: '/home/fabian/.atom/packages/build-tools-cpp/spec/profile-spec.coffee'    , row: '183', col: '32', start: 13, end: 87}],
  [{file: '/home/fabian/.atom/packages/build-tools-cpp/spec/profile-spec.coffee'    , row: '340', col: '15', start: 42, end: 116}],
  [{file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '794', col: '54', start: 25, end: 103}],
  [{file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '823', col: '30', start: 40, end: 118}],
  [{file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '756', col: '13', start: 46, end: 124}],
  [{file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '564', col: '44', start: 13, end: 91}],
  [{file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '110', col: '17', start: 20, end: 98}],
  [{file: 'node.js'                                                                 , row: '357', col: '13', start: 36, end: 49}],
  [],
  [],
  [],
  [{file: 'spec/regex-spec.coffee', row: '16', col: '18', start: 61, end: 88}]
]

profile 'Java', {
  stderr:
    pipeline: [
      {
        name: 'profile'
        config:
          profile: 'java'
      }
    ]
}, 'stderr',
[
  'Buildfile: /home/fabian/Projects/testing/java/build.xml'
  ''
  'compile: '
  '    [javac] /home/fabian/Projects/testing/java/build.xml:9: warning: \'includeantruntime\' was not set, defaulting to build.sysclasspath=last; set to false for repeatable builds'
  '    [javac] Compiling 1 source file to /home/fabian/Projects/testing/java/build/classes'
  '    [javac] /home/fabian/Projects/testing/java/src/Factorial.java:12: error: incompatible types'
  '    [javac]     if (fact)'
  '    [javac]         ^'
  '    [javac]   required: boolean'
  '    [javac]   found:    int'
  '    [javac] /home/fabian/Projects/testing/java/src/Factorial.java:15: error: array required, but int found'
  '    [javac]       while (fact[1])'
  '    [javac]                  ^'
  '    [javac] 2 errors'
  ''
  'BUILD FAILED'
  '/home/fabian/Projects/testing/java/build.xml: 9: Compile failed; see the compiler error output for details.'
  ''
  'Total time: 0 seconds'
],
[
  {type: 'error', message: 'incompatible types'           , file: '/home/fabian/Projects/testing/java/src/Factorial.java', row: '12'}
  {type: 'error', message: 'array required, but int found', file: '/home/fabian/Projects/testing/java/src/Factorial.java', row: '15'}
],
[
  [],
  [],
  [],
  [],
  [],
  [{file: '/home/fabian/Projects/testing/java/src/Factorial.java', row: '12', col: '0', start: 12, end: 67}],
  [],
  [],
  [],
  [],
  [{file: '/home/fabian/Projects/testing/java/src/Factorial.java', row: '15', col: '0', start: 12, end: 67}],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  []
]

profile 'Python', {
  stderr:
    pipeline: [
      {
        name: 'profile'
        config:
          profile: 'python'
      }
    ]
}, 'stderr',
[
  'Traceback (most recent call last): '
  '  File "/home/fabian/Projects/sonata/sonata/info.py", line 208, in on_viewport_resize'
  '    self.on_artwork_changed(None, self._pixbuf)'
  '  File "/home/fabian/Projects/sonata/sonata/info.py", line 534, in on_artwork_changed'
  '    (pix2, w, h) = img.aget_pixbuf_of_size(pixbuf, width)'
  'AttributeError: \'module\' object has no attribute \'aget_pixbuf_of_size\''
  '  File "./main.py", line 2'
  '    print "Hello World"'
  '                      ^'
  'SyntaxError: Missing parentheses in call to \'print\''
],
[
  {type: 'trace', message: 'AttributeError: \'module\' object has no attribute \'aget_pixbuf_of_size\'', file: '/home/fabian/Projects/sonata/sonata/info.py', row: '208'}
  {type: 'error', message: 'AttributeError: \'module\' object has no attribute \'aget_pixbuf_of_size\'', file: '/home/fabian/Projects/sonata/sonata/info.py', row: '534', trace: [
      {type: 'trace', text: '(pix2, w, h) = img.aget_pixbuf_of_size(pixbuf, width)', filePath: '/home/fabian/Projects/sonata/sonata/info.py', range: [[533, 0], [533, 9999]]}
      {type: 'trace', text: 'self.on_artwork_changed(None, self._pixbuf)'          , filePath: '/home/fabian/Projects/sonata/sonata/info.py', range: [[207, 0], [207, 9999]]}
    ]
  }
  {type: 'error', message: 'SyntaxError: Missing parentheses in call to \'print\''                     , file: './main.py', row: '2'}
],
[
  [],
  [{file: '/home/fabian/Projects/sonata/sonata/info.py', row: '208'}],
  [],
  [{file: '/home/fabian/Projects/sonata/sonata/info.py', row: '534'}],
  [],
  [],
  [{file: './main.py', row: '2'}],
  [],
  [],
  []
]

profile 'Modelsim', {
  stderr:
    pipeline: [
      {
        name: 'profile'
        config:
          profile: 'modelsim'
      }
    ]
}, 'stderr',
[
  'vcom -work work /home/chris/coding/vhdl_test/test.vhd'
  'Model Technology ModelSim SE-64 vcom 10.1g Compiler 2014.08 Aug  8 2014'
  '-- Loading package STANDARD'
  '-- Loading package TEXTIO'
  '-- Loading package std_logic_1164'
  '-- Loading package NUMERIC_STD'
  '-- Loading package test_pkg'
  '-- Compiling entity test'
  '-- Compiling architecture beh of test'
  '-- Loading entity test_sub'
  '** Error: /home/chris/coding/vhdl_test/test.vhd(106): (vcom-1484) Unknown formal identifier "data_in".'
  '** Error: /home/chris/coding/vhdl_test/test.vhd(278): VHDL Compiler exiting'
],
[
  {type: 'error', message: '(vcom-1484) Unknown formal identifier "data_in".', file: '/home/chris/coding/vhdl_test/test.vhd', row: '106'},
  {type: 'error', message: 'VHDL Compiler exiting', file: '/home/chris/coding/vhdl_test/test.vhd', row: '278'}
],
[
  [{file: '/home/chris/coding/vhdl_test/test.vhd', start: 16, end: 52}],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [{file: '/home/chris/coding/vhdl_test/test.vhd', row: '106', start: 10, end: 51}],
  [{file: '/home/chris/coding/vhdl_test/test.vhd', row: '278', start: 10, end: 51}]
]
