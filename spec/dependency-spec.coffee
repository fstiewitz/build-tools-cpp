DependencyView = require '../lib/dependency-view'
Projects = require '../lib/projects'

describe 'Dependency Panel', ->
  [spy, dep, projects, view, fixturesPath] = []

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    projects = new Projects('')
    projects.addProject(fixturesPath)
    spy = jasmine.createSpy('callback')
    view = new DependencyView(spy, projects)
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()
    projects.destroy()

  describe 'When no project has no commands', ->

    beforeEach ->
      view.show(fixturesPath, null, null)
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()

    afterEach ->
      view.hide()

    it 'displays a warning', ->
      select_project = view.project_from[0]
      select_command = view.command_from[0]

      expect(select_project.children[select_project.selectedIndex].innerHTML).toBe fixturesPath
      expect(select_command.children[select_command.selectedIndex].innerHTML).toBe 'Project has no commands'

      select_project = view.project_to[0]
      select_command = view.command_to[0]

      expect(select_project.children[select_project.selectedIndex].innerHTML).toBe fixturesPath
      expect(select_command.children[select_command.selectedIndex].innerHTML).toBe 'Project has no commands'

    it 'does not accept the input', ->
      view.find('.btn-primary').click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      expect(view.find('#source-command-none').hasClass('hidden')).toBeFalsy()
      expect(view.find('#dest-command-none').hasClass('hidden')).toBeFalsy()
      expect(spy).not.toHaveBeenCalled()

  describe 'When a project has commands', ->
    project = null

    cmd = {
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

    beforeEach ->
      project = projects.getProject fixturesPath
      cmd.name = 'Test command'
      project.addCommand cmd
      cmd.name = 'Test command 2'
      project.addCommand cmd

    afterEach ->
      project.removeCommand 'Test command'
      project.removeCommand 'Test command 2'

    describe 'and a dependency is created', ->

      beforeEach ->
        view.show(fixturesPath, null, null)
        expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()

      afterEach ->
        view.hide()

      it 'displays the commands as a default', ->
        select_project = view.project_from[0]
        select_command = view.command_from[0]

        expect(select_project.children[select_project.selectedIndex].innerHTML).toBe fixturesPath
        expect(select_command.children[select_command.selectedIndex].innerHTML).toBe 'Test command'
        expect(select_command.children[1].innerHTML).toBe 'Test command 2'

        select_project = view.project_to[0]
        select_command = view.command_to[0]

        expect(select_project.children[select_project.selectedIndex].innerHTML).toBe fixturesPath
        expect(select_command.children[select_command.selectedIndex].innerHTML).toBe 'Test command'
        expect(select_command.children[1].innerHTML).toBe 'Test command 2'

      it 'accepts the input', ->
        view.find('.btn-primary').click()
        expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
        expect(spy).toHaveBeenCalledWith(null, {
          from:
            project: ''
            command: 'Test command'
          to:
            project: fixturesPath
            command: 'Test command'
          })

    describe 'and a dependency is edited', ->

      beforeEach ->
        dep = {
          from:
            project: fixturesPath
            command: 'Test command'
          to:
            project: fixturesPath
            command: 'Test command 2'
        }
        project.addDependency dep
        view.show(fixturesPath, dep, 1)

      afterEach ->
        view.hide()
        project.removeDependency 0

      it 'displays the dependency to edit', ->
        select_project = view.project_from[0]
        select_command = view.command_from[0]

        expect(select_project.children[select_project.selectedIndex].innerHTML).toBe fixturesPath
        expect(select_command.children[select_command.selectedIndex].innerHTML).toBe 'Test command'
        expect(select_command.children[1].innerHTML).toBe 'Test command 2'

        select_project = view.project_to[0]
        select_command = view.command_to[0]

        expect(select_project.children[select_project.selectedIndex].innerHTML).toBe fixturesPath
        expect(select_command.children[select_command.selectedIndex].innerHTML).toBe 'Test command 2'
        expect(select_command.children[0].innerHTML).toBe 'Test command'

      it 'accepts the input', ->
        view.command_to[0].selectedIndex = 0
        view.find('.btn-primary').click()
        expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
        expect(spy).toHaveBeenCalledWith(1, {
          from:
            project: ''
            command: 'Test command'
          to:
            project: fixturesPath
            command: 'Test command'
          })
