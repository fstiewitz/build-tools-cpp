Projects = require '../lib/projects'
path = require 'path'
{$} = require 'atom-space-pen-views'

describe 'Projects', ->
  [projects, fixturesPath, root1, root2] = []

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    projects = new Projects('')
    expect(projects.data).toEqual {}
    root1 = path.join(fixturesPath, 'root1')
    root2 = path.join(fixturesPath, 'root2')

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
        profile: 'apm_test',
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
    command.name = 'Test command 2'
    projects.getProject(root1).addCommand command
    projects.getProject(root1).addDependency dependency
    dependency = {
      from:
        command: ''
      to:
        project: ''
        command: 'Test command'
    }
    dependency.from.command = 'Test command'
    dependency.to.project = root2
    projects.getProject(root1).addDependency dependency
    projects.getProject(root1).setKey 'make', {
      project: root1,
      command: 'Test command'
    }

    expect(projects.getProject(root1).commands.length).toBe 2
    expect(projects.getProject(root1).dependencies.length).toBe 2
    expect(projects.getProject(root2).commands.length).toBe 1
    expect(projects.getProject(root2).dependencies.length).toBe 0
    expect(projects.getProject(root1).commands[0].targetOf.length).toBe 2
    expect(projects.getProject(root1).commands[1].targetOf.length).toBe 0
    expect(projects.getProject(root2).commands[0].targetOf.length).toBe 1
    expect(projects.getProject(root1).key.make).toEqual {
      project: root1,
      command: 'Test command'
    }
    expect(projects.getProject(root1).key.configure).toBeNull()
    expect(projects.getProject(root1).key.preconfigure).toBeNull()
    expect(projects.getProject(root2).key.make).toBeNull()
    expect(projects.getProject(root2).key.configure).toBeNull()
    expect(projects.getProject(root2).key.preconfigure).toBeNull()

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
    project = null

    beforeEach ->
      project = projects.getProject root2
      expect(project['commands'].length).toBe 1
      project.addCommand data

    it 'creates a new command', ->
      expect(project['commands'].length).toBe 2
      expect(project['commands'][1].project).toBe root2
      expect(project['commands'][1].name).toBe 'Test command 2'

    it 'upgrades the version property if input is pre-3.0', ->
      expect(project['commands'][1].version).toBe 1
      expect(project['commands'][1].stderr.highlighting).toBe 'hc'
      expect(project['commands'][1].stderr.profile).toBe 'gcc_clang'

  describe 'When assigning a custom key binding', ->
    project = null

    beforeEach ->
      project = projects.getProject root2
      command = projects.getProject(root1).commands[0]
      project.setKey 'make', {
        project: command.project
        command: command.name
      }

    it 'sets the key binding', ->
      expect(project.key.make).toEqual {
        project: root1
        command: 'Test command'
      }

    it 'links the command to the project', ->
      expect(projects.getProject(root1).commands[0].targetOf).toContain {
        project: root2
        command: null
      }

    describe 'When removing the custom key binding', ->
      project = null

      beforeEach ->
        project = projects.getProject root2
        project.clearKey 'make'

      it 'removes the key binding', ->
        expect(project.key.make).toBeNull()

      it 'removes the link', ->
        expect(projects.getProject(root1).commands[0].targetOf).not.toContain {
          project: root2
          command: null
        }

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
      expect(targetOf).toContain {
        project: root1
        command: 'Test command 2'
      }

  describe 'When editing a command', ->
    [command_src, command_target, dependency, project] = []

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
      expect(command_src.targetOf.length).toBe 2
      expect(command_src.targetOf[0].project).toBe root1
      expect(command_src.targetOf[0].command).toBe 'Test command 2'

    it 'changes the dependencies that point to the original command', ->
      expect(dependency.to.command).toBe 'Test command 3'

    it 'changes the targetOf property of its targets', ->
      expect(command_target.targetOf.length).toBe 1
      expect(command_target.targetOf[0].command).toBe 'Test command 3'

    it 'changes its key binding', ->
      expect(project.key.make).toEqual {
        project: root1,
        command: 'Test command 3'
      }

  describe 'When editing a dependency', ->
    [dependency, command_old, command_new] = []

    beforeEach ->
      project = projects.getProject root1
      dependency = project.dependencies[0]
      command_old = project.getCommand dependency.to.command
      command_new = projects.getProject(root2).getCommand 'Test command'
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

    it 'removes the reference in the old target command', ->
      expect(command_old.targetOf.length).toBe 1

    it 'adds a reference to the new target command', ->
      expect(command_new.targetOf).toContain {
        project: root1
        command: 'Test command 2'
      }

  describe 'When moving a command', ->
    project = null

    beforeEach ->
      project = projects.getProject root1
      expect(project.commands.length).toBe 2
      expect((project.getCommandByIndex 0).name).toBe 'Test command'
      expect((project.getCommandByIndex 1).name).toBe 'Test command 2'

    it 'can move down', ->
      project.moveCommand 'Test command 2', -1
      expect((project.getCommandByIndex 0).name).toBe 'Test command 2'
      expect((project.getCommandByIndex 1).name).toBe 'Test command'
    it 'can move up', ->
      project.moveCommand 'Test command', 1
      expect((project.getCommandByIndex 0).name).toBe 'Test command 2'
      expect((project.getCommandByIndex 1).name).toBe 'Test command'

  describe 'When moving a dependency', ->
    project = null

    beforeEach ->
      project = projects.getProject root1
      expect(project.dependencies.length).toBe 2
      expect(project.dependencies[0].from.command).toBe 'Test command 2'
      expect(project.dependencies[1].from.command).toBe 'Test command'

    it 'can move down', ->
      project.moveDependency 1, -1
      expect(project.dependencies[0].from.command).toBe 'Test command'
      expect(project.dependencies[1].from.command).toBe 'Test command 2'

    it 'can move up', ->
      project.moveDependency 0, 1
      expect(project.dependencies[0].from.command).toBe 'Test command'
      expect(project.dependencies[1].from.command).toBe 'Test command 2'

  describe 'When executing a command', ->
    [project, command, command_list] = []

    beforeEach ->
      project = projects.getProject root1
      command = project.getCommandByIndex 0
      projects.getProject(root2).addDependency {
        from:
          command: 'Test command'
        to:
          project: root1
          command: 'Test command 2'
      }
      command_list = projects.generateDependencyList command

    afterEach ->
      command_list = null

    it 'generates a dependency list without any loops', ->
      expect(command_list.length).toBe 3
      expect(command_list[0].project).toBe root1
      expect(command_list[0].name).toBe 'Test command 2'
      expect(command_list[1].project).toBe root2
      expect(command_list[1].name).toBe 'Test command'
      expect(command_list[2].project).toBe root1
      expect(command_list[2].name).toBe 'Test command'

    it 'converts all information before giving them to BufferedProcess', ->
      expect(command.name).toBe 'Test command'
      {cmd, args, env, cwd} = command.parseCommand()
      expect(cmd).toBe 'pwd'
      expect(args).toEqual ["Hello World", "test"]
      expect(cwd).toBe (path.join(root1, command.wd))

  describe 'When removing a command', ->
    [project, command, dependencies, command_target] = []

    beforeEach ->
      project = projects.getProject root1
      command = project.getCommand 'Test command'
      dependencies = project.dependencies
      command_target = projects.getProject(root2).getCommand 'Test command'
      expect(command_target.targetOf).toContain {
        project: root1
        command: 'Test command'
      }
      project.removeCommand 'Test command'

    it 'removes the command', ->
      expect(project.commands).not.toContain(command)

    it 'removes the dependencies associated with it', ->
      expect(project.dependencies).not.toContain(dependencies)

    it 'removes the references in targetOf properties', ->
      expect(command_target.targetOf).not.toContain {
        project: root1
        command: 'Test command'
      }

    it 'removes its key binding', ->
      expect(project.key.make).toBeNull()

  describe 'When removing a dependency', ->
    [project, dependency, command_target] = []

    beforeEach ->
      project = projects.getProject root1
      dependency = project.dependencies[1]
      command_target = projects.getProject(root2).getCommand 'Test command'
      expect(command_target.targetOf).toContain {
        project: root1
        command: 'Test command'
      }
      project.removeDependency 1

    it 'removes the dependency', ->
      expect(project.dependencies).not.toContain(dependency)

    it 'removes the reference in targetOf properties', ->
      expect(command_target.targetOf).not.toContain {
        project: root1
        command: 'Test command'
      }
