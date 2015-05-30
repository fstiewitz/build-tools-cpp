main = require '../lib/main'
path = require 'path'

describe 'Project', ->
  [workspaceElement, activationPromise, fixturesPath, root1, root2] = []

  execute = (callback) ->
    atom.commands.dispatch(workspaceElement, 'build-tools-cpp:show')
    waitsForPromise -> activationPromise
    runs callback

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('build-tools-cpp')
    fixturesPath = atom.project.getPaths()[0]
    root1 = path.join(fixturesPath,'root1')
    root2 = path.join(fixturesPath,'root2')

  describe 'On package activation', ->
    it 'creates/loads the project file', ->
      execute ->
        expect(main.projects.filename).not.toBe ''
        expect(main.projects.emitter).toBeDefined

  describe 'When adding a project', ->
    it 'creates a new project', ->
      execute ->
        expect(main.projects.data[root1]).toBeUndefined
        main.projects.addProject root1
        expect(main.projects.data[root1]).toBeDefined
        expect(main.projects.data[root1]['path']).toBeDefined
        expect(main.projects.data[root1]['dependencies']).toBeDefined
        expect(main.projects.data[root1]['commands']).toBeDefined

  describe 'When finding old test command', ->
    it 'will be removed', ->
      execute ->
        project = main.projects.getProject root1
        if project.hasCommand 'Test command'
          expect(project.commands[0]).toBeDefined
          project.removeCommand 'Test command'
        expect(project.commands[0]).toBeUndefined

  describe 'When adding a command', ->
    it 'creates a new command', ->
      execute ->
        project = main.projects.getProject root1
        expect(main.projects.data[root1]['commands'].length).toBe 0
        data = {
          name: 'Test command',
          command: 'pwd',
          wd: 'sub0',
          shell: false,
          stdout: {
            file: false,
            highlighting: 'ha',
            lint: false
          }
          stderr: {
            file: true,
            highlighting: 'hc',
            lint: false
          }
        }
        project.addCommand data
        expect(project.getCommand('Test command').project).toBe root1
        expect(project.getCommand('Test command').wd).toBe 'sub0'
