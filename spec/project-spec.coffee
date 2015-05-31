Projects = require '../lib/projects'
path = require 'path'
fs = require 'fs'

describe 'Project', ->
  [projects, fixturesPath, root1, root2] = []

  beforeEach ->
    projects = new Projects('spec/build-tools-cpp.projects')
    fixturesPath = atom.project.getPaths()[0]
    root1 = path.join(fixturesPath,'root1')
    root2 = path.join(fixturesPath,'root2')

  afterEach ->
    projects.destroy()

  describe 'On package activation', ->
    it 'creates/loads the project file', ->
      expect(projects.filename).not.toBe ''
      expect(projects.emitter).toBeDefined()

  describe 'When adding a project', ->
    it 'creates a new project', ->
      expect(projects.data[root1]).toBeUndefined()
      projects.addProject root1
      expect(projects.data[root1]).toBeDefined()
      expect(projects.data[root1]['path']).toBeDefined()
      expect(projects.data[root1]['dependencies']).toBeDefined()
      expect(projects.data[root1]['commands']).toBeDefined()

  describe 'When adding a command', ->
    it 'creates a new command', ->
      project = projects.getProject root1
      expect(projects.data[root1]['commands'].length).toBe 0
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
      project = projects.getProject root1
      expect(projects.data[root1]['commands'].length).toBe 2
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
      project = projects.getProject root1
      expect(project.commands.length).toBe 2
      expect((project.getCommandByIndex 0).name).toBe 'Test command'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 3'
      project.moveCommand 'Test command 3', -1
      expect((project.getCommandByIndex 0).name).toBe 'Test command 3'
      expect((project.getCommandByIndex 1).name).toBe 'Test command'
    it 'can move up', ->
      project = projects.getProject root1
      expect(project.commands.length).toBe 2
      expect((project.getCommandByIndex 0).name).toBe 'Test command 3'
      expect((project.getCommandByIndex 1).name).toBe 'Test command'
      project.moveCommand 'Test command 3', 1
      expect((project.getCommandByIndex 0).name).toBe 'Test command'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 3'

  describe 'When executing a command', ->
    it 'converts all information before giving them to BufferedProcess', ->
      project = projects.getProject root1
      command = project.getCommandByIndex 0
      expect(command.name).toBe 'Test command'
      {cmd,args,env,cwd} = command.parseCommand()
      expect(cmd).toBe 'pwd'
      expect(args).toEqual ["Hello World", "test"]
      expect(cwd).toBe (path.join(root1,command.wd))

  describe 'When removing a project', ->
    it 'removes the project', ->
      expect(projects.getProject(root1)).toBeDefined()
      cmd = (projects.getProject root1).getCommandByIndex 0
      projects.removeProject(root1)
      expect(projects.getProject(root1)).toBeUndefined()
      fs.unlinkSync 'spec/build-tools-cpp.projects'
