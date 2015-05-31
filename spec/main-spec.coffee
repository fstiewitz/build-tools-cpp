main = require '../lib/main'

describe 'On package activation', ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('build-tools-cpp')
    atom.commands.dispatch(workspaceElement, 'build-tools-cpp:show')
    waitsForPromise -> activationPromise

  it 'loads the project configuration', ->
    expect(main.Projects).toBeDefined()
    expect(main.projects).toBeDefined()
