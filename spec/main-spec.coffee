main = '../lib/main'

describe 'On package activation', ->
  [workspaceElement, activationPromise] = []

  execute = (callback) ->
    atom.commands.dispatch(workspaceElement, 'build-tools-cpp:show')
    waitsForPromise -> activationPromise
    runs callback

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('build-tools-cpp')

  it 'loads the project configuration', ->
    execute ->
      expect(main.Projects).not.toBeNull
      expect(main.projects).not.toBeNull
