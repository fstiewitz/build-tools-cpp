Profile = require './profile'

Profile.profile 'GCC/Clang', {
  stderr:
    profile: 'gcc_clang'
    highlighting: 'hc'
}, 'stderr', ['language-c'],
[
  'In file included from test/src/def.h:32:0,',
  '                 from test/src/gen.h:31,',
  '                 from test/src/gen.c:27:',
  'should be traced too',
  '/usr/include/stdlib.h:483:13: note: expected ‘void *’ but argument is of type ‘const void *’',
  ' extern void free (void *__ptr) __THROW;',
  '             ^',
  'test/src/gen.c:126:6: error: implicit declaration of function ‘print_element’ [-Wimplicit-function-declaration]',
  '      print_element(input);',
  '      ^'
],
[
  {file: 'test/src/def.h'       , row:'32' , col:'0'      , type:'trace'  , highlighting:'note', message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
  {file: 'test/src/gen.h'       , row:'31' , col:undefined, type:'trace'  , highlighting:'note', message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
  {file: 'test/src/gen.c'       , row:'27' , col:undefined, type:'trace'  , highlighting:'note', message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
  {file: '/usr/include/stdlib.h', row:'483', col:'13'     , type:'note',                         message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
  {file: 'test/src/gen.c'       , row:'126', col:'6'      , type:'error'  ,                         message: 'implicit declaration of function ‘print_element’ [-Wimplicit-function-declaration]'},
],
[
  [{file: 'test/src/def.h'       , row:'32' , col:'0'      , start:22, end:40}],
  [{file: 'test/src/gen.h'       , row:'31' , col:undefined, start:22, end:38}],
  [{file: 'test/src/gen.c'       , row:'27' , col:undefined, start:22, end:38}],
  [],
  [{file: '/usr/include/stdlib.h', row:'483', col:'13'     , start:0 , end:27}],
  [],
  [],
  [{file: 'test/src/gen.c'       , row:'126', col:'6'      , start:0 , end:19}],
  [],
  []
]

Profile.profile 'apm test', {
  stderr:
    profile: 'apm_test'
    highlighting: 'hc'
}, 'stderr', ['language-javascript', 'language-coffee-script'],
[
  '.................................................FF...............................................'
  ''
  'Profiles'
  '  apm test'
  '    on ::in with multi line match'
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
  'Linter Service'
  '  it has all necessary properties'
  '    Expected Function not to be defined. (spec/linter-spec.coffee:9:31)'
],
[
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.', file: '/home/fabian/.atom/packages/build-tools-cpp/spec/profile-spec.coffee'    , row: '340', col: '15' },
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.', file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '794', col: '54' },
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.', file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '823', col: '30'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.', file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '756', col: '13'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.', file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '564', col: '44'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.', file: '/home/fabian/Apps/atom-build/Atom/resources/app.asar/node_modules/q/q.js', row: '110', col: '17'},
  {type: 'trace', message: 'Error: Expected undefined to be \'test/src/def.h\'.', file: 'node.js'                                                                 , row: '357', col: '13'},
  {type: 'error', message: 'Error: Expected undefined to be \'test/src/def.h\'.', file: '/home/fabian/.atom/packages/build-tools-cpp/spec/profile-spec.coffee'    , row: '183', col: '32' }
  {type: 'error', message: 'Expected Function not to be defined'                , file: 'spec/linter-spec.coffee'                                                 , row: '9'  , col: '31'}
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
  [{file: 'spec/linter-spec.coffee', row: '9', col: '31', start: 42, end: 69}]
]
