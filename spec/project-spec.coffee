Projects = require '../lib/projects'
path = require 'path'
fs = require 'fs'
{$} = require 'atom-space-pen-views'

describe 'Project', ->
  [projects, fixturesPath, root1, root2] = []

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    projects = new Projects('')
    expect(projects.data).toEqual {}
    root1 = path.join(fixturesPath,'root1')
    root2 = path.join(fixturesPath,'root2')

    projects.addProject root1
    projects.addProject root2

    command = {
      name: 'Test command',
      command: 'pwd "Hello World" test',
      wd: 'sub0',
      shell: false,
      wildcards: false,
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

    dependency = {
      from:
        command: 'Test command 2'
      to: {
        project: root1,
        command: 'Test command'
      }
    }

    projects.getProject(root1).addCommand command
    projects.getProject(root2).addCommand command
    command = $.extend({}, command)
    command.name = 'Test command 2'
    projects.getProject(root1).addCommand command
    projects.getProject(root1).addDependency dependency
    dependency = $.extend({}, dependency)
    dependency.from.command = 'Test command'
    dependency.to.project = root2
    projects.getProject(root1).addDependency dependency

    expect(projects.getProject(root1).commands.length).toBe 2
    expect(projects.getProject(root1).dependencies.length).toBe 2
    expect(projects.getProject(root2).commands.length).toBe 1
    expect(projects.getProject(root2).dependencies.length).toBe 0
    expect(projects.getProject(root1).commands[0].targetOf.length).toBe 1
    expect(projects.getProject(root1).commands[1].targetOf.length).toBe 0
    expect(projects.getProject(root2).commands[0].targetOf.length).toBe 1

  afterEach ->
    projects.destroy()

  describe 'On package activation', ->
    it 'creates/loads the project file', ->
      expect(projects.emitter).toBeDefined()

  describe 'When adding a project', ->
    it 'creates a new project', ->
      expect(projects.data[root1]).toBeDefined()
      expect(projects.data[root1]['path']).toBeDefined()
      expect(projects.data[root1]['dependencies'].length).toBe 2
      expect(projects.data[root1]['commands'].length).toBe 2
      expect(projects.data[root2]).toBeDefined()
      expect(projects.data[root2]['path']).toBeDefined()
      expect(projects.data[root2]['dependencies'].length).toBe 0
      expect(projects.data[root2]['commands'].length).toBe 1

  describe 'When adding a command', ->
    it 'creates a new command', ->
      project = projects.getProject root2
      expect(project['commands'].length).toBe 1
      data = {
        name: 'Test command 2',
        command: 'pwd',
        wd: 'sub0',
        shell: false,
        wildcards: false,
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
      expect(project['commands'].length).toBe 2
      expect(project['commands'][1].project).toBe root2
      expect(project['commands'][1].name).toBe 'Test command 2'

  describe 'When adding a dependency', ->
    project = null

    beforeEach ->
      project = projects.getProject root1
      expect(project['dependencies'].length).toBe 2
      dependency = {
        from:
          command: 'Test command 2'
        to: {
          project: root2,
          command: 'Test command'
        }
      }
      project.addDependency dependency

    it 'adds a dependency', ->
      expect(project.dependencies.length).toBe 3
      dependency = project.dependencies[1]
      expect(dependency.from.project).toBe root1
      expect(dependency.to.command).toBe 'Test command'

    it 'links the target to the source command', ->
      targetOf = projects.getProject(root2).getCommand('Test command').targetOf
      expect(targetOf.length).toBe 2
      expect(targetOf[1]).toEqual {
        project: root1
        command: 'Test command 2'
      }

  describe 'When editing a command', ->
    [command_src, command_target, dependency] = []

    beforeEach ->
      project = projects.getProject root1
      command_src = project.getCommand 'Test command'
      command_target = projects.getProject(root2).getCommand('Test command')
      dependency = project.dependencies[0]
      data = {
        name: 'Test command 3',
        command: 'pwd',
        wd: 'sub0',
        shell: false,
        wildcards: true,
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
      project.replaceCommand command_src.name, data
      command_src = project.getCommand 'Test command 3'

    it 'replaces the command with the new one', ->
      expect(command_src.name).toBe 'Test command 3'

    it 'copies the targetOf property', ->
      expect(command_src.targetOf.length).toBe 1
      expect(command_src.targetOf[0].project).toBe root1
      expect(command_src.targetOf[0].command).toBe 'Test command 2'

    it 'changes the dependencies that point to the original command', ->
      expect(dependency.to.command).toBe 'Test command 3'

    it 'changes the targetOf property of its targets', ->
      expect(command_target.targetOf.length).toBe 1
      expect(command_target.targetOf[0].command).toBe 'Test command 3'

  describe 'When editing a dependency', ->
    [dependency, command_target] = []

    beforeEach ->
      project = projects.getProject root1
      dependency = project.dependencies[0]
      command_target = project.getCommand dependency.to.command
      data = {
        from:
          project: root1
          command: 'Test command 2'
        to:
          project: root2
          command: 'Test command'
      }
      project.replaceDependency 0, data
      dependency = project.dependencies[0]

    it 'replaces the dependency with the new one', ->
      expect(dependency.to.project).toBe root2

    it 'changes the targetOf property of its target', ->
      expect(command_target.targetOf.length).toBe 2
      expect(command_target.targetOf[1].command).toBe 'Test command 2'

  xdescribe 'When editing a dependency', ->
    it 'edits the dependency', ->
      project = projects.getProject root1
      expect(projects.data[root1]['dependencies'].length).toBe 2
      data = {
        from:
          project: root1
          command: 'Test command 2'
        to:
          project: root2
          command: 'Test command 4'
      }
      project.replaceDependency 1, data
      dependencies = project.dependencies
      expect(dependencies.length).toBe 2
      expect(dependencies[0].from.command).toBe 'Test command 2'
      command = projects.getProject(root2).getCommand('Test command 4')
      expect(command.targetOf.length).toBe 3
      expect(command.targetOf[0].command).toBe 'Test command 2'

  xdescribe 'When moving a command', ->
    it 'can move down', ->
      project = projects.getProject root2
      expect(project.commands.length).toBe 2
      expect((project.getCommandByIndex 0).name).toBe 'Test command 2'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 4'
      project.moveCommand 'Test command 4', -1
      expect((project.getCommandByIndex 0).name).toBe 'Test command 4'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 2'
    it 'can move up', ->
      project = projects.getProject root2
      expect(project.commands.length).toBe 2
      expect((project.getCommandByIndex 0).name).toBe 'Test command 4'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 2'
      project.moveCommand 'Test command 4', 1
      expect((project.getCommandByIndex 0).name).toBe 'Test command 2'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 4'

  xdescribe 'When executing a command', ->
    it 'converts all information before giving them to BufferedProcess', ->
      project = projects.getProject root1
      command = project.getCommandByIndex 0
      expect(command.name).toBe 'Test command'
      {cmd,args,env,cwd} = command.parseCommand()
      expect(cmd).toBe 'pwd'
      expect(args).toEqual ["Hello World", "test"]
      expect(cwd).toBe (path.join(root1,command.wd))

  xdescribe 'When removing a command', ->
    it 'removes the command', ->
      project = projects.getProject root1
      command = project.getCommand 'Test command 2'
      expect(command).toBeDefined()
      expect(projects.getProject(root2).getCommand('Test command 4').targetOf.length).toBe 3
      project.removeCommand 'Test command 2'
      expect(project.getCommand 'Test command 2').toBeUndefined()
      expect(projects.getProject(root2).getCommand('Test command 4').targetOf.length).toBe 1

  xdescribe 'When removing a dependency', ->
    it 'removes the dependency', ->
      project = projects.getProject root2
      dependency = project.dependencies[0]
      target = projects.getProject(root2).getCommand 'Test command 4'
      expect(dependency).toBeDefined()
      expect(dependency.to.command).toBe 'Test command 4'
      expect(target.targetOf[0].command).toBe dependency.from.command
      project.removeDependency 0
      dependency = project.dependencies[0]
      expect(dependency).toBeUndefined()
      expect(target.targetOf.length).toBe 0

  xdescribe 'When removing a project', ->
    it 'removes the project', ->
      expect(projects.getProject(root1)).toBeDefined()
      projects.removeProject(root1)
      expect(projects.getProject(root1)).toBeUndefined()
