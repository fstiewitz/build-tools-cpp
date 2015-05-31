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
    atom.commands.dispatch(workspaceElement, 'build-tools-cpp:show')
    waitsForPromise -> activationPromise
    runs ->
      fixturesPath = atom.project.getPaths()[0]
      root1 = path.join(fixturesPath,'root1')
      root2 = path.join(fixturesPath,'root2')

  describe 'On package activation', ->
    it 'creates/loads the project file', ->
      expect(main.projects.filename).not.toBe ''
      expect(main.projects.emitter).toBeDefined()

  describe 'When adding a project', ->
    it 'creates a new project', ->
      expect(main.projects.data[root1]).toBeUndefined()
      main.projects.addProject root1
      expect(main.projects.data[root1]).toBeDefined()
      expect(main.projects.data[root1]['path']).toBeDefined()
      expect(main.projects.data[root1]['dependencies']).toBeDefined()
      expect(main.projects.data[root1]['commands']).toBeDefined()

  describe 'When finding old test command', ->
    it 'will be removed', ->
      project = main.projects.getProject root1
      while project.commands.length isnt 0
        expect(project.getCommandByIndex 0).toBeDefined()
        cmd = project.getCommandByIndex 0
        project.removeCommand cmd.name
        expect(project.getCommand cmd.name).toBeUndefined()
      expect(project.commands.length).toBe 0

  describe 'When adding a command', ->
    it 'creates a new command', ->
      project = main.projects.getProject root1
      expect(main.projects.data[root1]['commands'].length).toBe 0
      data = {
        name: 'Test command',
        command: 'pwd "Hello World" test',
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
      data2 = {
        name: 'Test command 2',
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
      project.addCommand data2
      expect(project.getCommand('Test command').project).toBe root1
      expect(project.getCommand('Test command').wd).toBe 'sub0'
      expect(project.getCommand('Test command 2').project).toBe root1
      expect(project.getCommand('Test command 2').wd).toBe 'sub0'

  describe 'When editing a command', ->
    it 'replaces the commands', ->
      project = main.projects.getProject root1
      expect(main.projects.data[root1]['commands'].length).toBe 2
      command = project.getCommand 'Test command 2'
      expect(command.name).toBe 'Test command 2'
      data = {
        name: 'Test command 3',
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
      project.replaceCommand command.name, data
      expect(project.getCommand 'Test command 2').toBeUndefined()
      expect(project.getCommand 'Test command 3').toBeDefined()

  describe 'When moving a command', ->
    it 'can move down', ->
      project = main.projects.getProject root1
      expect(project.commands.length).toBe 2
      expect((project.getCommandByIndex 0).name).toBe 'Test command'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 3'
      project.moveCommand 'Test command 3', -1
      expect((project.getCommandByIndex 0).name).toBe 'Test command 3'
      expect((project.getCommandByIndex 1).name).toBe 'Test command'
    it 'can move up', ->
      project = main.projects.getProject root1
      expect(project.commands.length).toBe 2
      expect((project.getCommandByIndex 0).name).toBe 'Test command 3'
      expect((project.getCommandByIndex 1).name).toBe 'Test command'
      project.moveCommand 'Test command 3', 1
      expect((project.getCommandByIndex 0).name).toBe 'Test command'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 3'

  describe 'When executing a command', ->
    it 'converts all information before giving them to BufferedProcess', ->
      project = main.projects.getProject root1
      command = project.getCommandByIndex 0
      expect(command.name).toBe 'Test command'
      {cmd,args,env,cwd} = command.parseCommand()
      expect(cmd).toBe 'pwd'
      expect(args).toEqual ["Hello World", "test"]
      expect(cwd).toBe (path.join(root1,command.wd))

  describe 'When removing a project', ->
    it 'removes the project', ->
      expect(main.projects.getProject(root1)).toBeDefined()
      cmd = (main.projects.getProject root1).getCommandByIndex 0
      main.projects.removeProject(root1)
      expect(main.projects.getProject(root1)).toBeUndefined()
      p=main.projects.getProject(fixturesPath)
      if p?.getCommand('Test command') is undefined
        main.projects.addProject fixturesPath
        main.projects.getProject(fixturesPath).addCommand(cmd)
