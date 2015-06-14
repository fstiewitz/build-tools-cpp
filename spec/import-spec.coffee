ImportView = require '../lib/import-view'
Projects = require '../lib/projects'
path = require 'path'
{$} = require 'atom-space-pen-views'

describe 'Import Panel', ->
  [spy, projects, command, dependency, view, fixturesPath, root1, root2] = []

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
    expect(projects.getProject(root1).commands.length).toBe 2
    expect(projects.getProject(root1).dependencies.length).toBe 2
    expect(projects.getProject(root2).commands.length).toBe 1
    expect(projects.getProject(root2).dependencies.length).toBe 0
    expect(projects.getProject(root1).commands[0].targetOf.length).toBe 1
    expect(projects.getProject(root1).commands[1].targetOf.length).toBe 0
    expect(projects.getProject(root2).commands[0].targetOf.length).toBe 1
    spy = jasmine.createSpy('callback')
    view = new ImportView(projects)
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()
    projects.destroy()

  describe 'When panel is opened', ->
    describe 'for command import', ->
      p = null

      beforeEach ->
        view.show(false, spy, root1)
        p = view.find('.project')
        expect(p.length).toBe 2

      afterEach ->
        view.hide()

      it 'opens the panel', ->
        expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()

      it 'displays the commands', ->
        expect(view.find('.item').length).toBe 3

      it 'only expands the current project', ->
        expect(p[0].parentNode.classList.contains 'collapsed').toBeFalsy()
        expect(p[1].parentNode.classList.contains 'collapsed').toBeTruthy()

      describe 'When clicking on a project', ->
        it 'expands the clicked on project', ->
          p[1].click()
          expect(p[1].parentNode.classList.contains 'collapsed').toBeFalsy()

      describe 'When clicking on a command', ->

        beforeEach ->
          $($(p[0].parentNode).find('.item')[0]).click()
          $($(p[0].parentNode).find('.item')[1]).click()

        afterEach ->
          view.find('.selected').removeClass 'selected'

        it 'selects the clicked on command', ->
          expect(view.find('.selected').length).toBe 1
          expect(view.find('.selected').children()[0].innerHTML).toBe 'Test command 2'

        it 'deselects all other commands', ->
          expect($(p[0].parentNode).find('.item')[0].classList.contains 'selected').toBeFalsy()

      describe 'When cancelling', ->
        it 'cancels', ->
          view.find('.btn-error').click()
          expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
          expect(spy).not.toHaveBeenCalled()

      describe 'When accepting', ->
        describe 'and input is invalid ( nothing selected )', ->

          beforeEach ->
            view.find('.btn-primary').click()

          it 'does not detach', ->
            expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()

          it 'shows an error message', ->
            expect(view.find('.error').hasClass('hidden')).toBeFalsy()

          it 'does not call the callback function', ->
            expect(spy).not.toHaveBeenCalled()

        describe 'and input is valid ( command is selected )', ->

          beforeEach ->
            $($(p[0].parentNode).find('.item')[1]).click()
            view.find('.btn-primary').click()

          it 'detaches', ->
            expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()

          it 'calls the callback function', ->
            expect(spy).toHaveBeenCalled()
            args = spy.mostRecentCall.args[0]
            expect(args.name).toBe 'Test command 2'

    describe 'for dependency import', ->
      p = null

      beforeEach ->
        view.show(true, spy, root1)
        p = view.find('.project')
        expect(p.length).toBe 2

      afterEach ->
        view.hide()

      it 'opens the panel', ->
        expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()

      it 'displays the dependencies', ->
        expect(view.find('.item').length).toBe 2

      it 'only expands the current project', ->
        expect(p[0].parentNode.classList.contains 'collapsed').toBeFalsy()
        expect(p[1].parentNode.classList.contains 'collapsed').toBeTruthy()

      describe 'When clicking on a project', ->
        it 'expands the clicked on project', ->
          p[1].click()
          expect(p[1].parentNode.classList.contains 'collapsed').toBeFalsy()

      describe 'When clicking on a dependency', ->

        beforeEach ->
          $($(p[0].parentNode).find('.item')[0]).click()
          $($(p[0].parentNode).find('.item')[1]).click()

        afterEach ->
          view.find('.selected').removeClass 'selected'

        it 'selects the clicked on dependency', ->
          expect(view.find('.selected').length).toBe 1
          expect(view.find('.selected').children()[0].innerHTML).toContain root2+':Test command'

        it 'deselects all other dependencies', ->
          expect($(p[0].parentNode).find('.item')[0].classList.contains 'selected').toBeFalsy()

      describe 'When cancelling', ->
        it 'cancels', ->
          view.find('.btn-error').click()
          expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
          expect(spy).not.toHaveBeenCalled()

      describe 'When accepting', ->
        describe 'and input is invalid ( nothing selected )', ->

          beforeEach ->
            view.find('.btn-primary').click()

          it 'does not detach', ->
            expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()

          it 'shows an error message', ->
            expect(view.find('.error').hasClass('hidden')).toBeFalsy()

          it 'does not call the callback function', ->
            expect(spy).not.toHaveBeenCalled()

        describe 'and input is valid ( command is selected )', ->

          beforeEach ->
            $($(p[0].parentNode).find('.item')[1]).click()
            view.find('.btn-primary').click()

          it 'detaches', ->
            expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()

          it 'calls the callback function', ->
            expect(spy).toHaveBeenCalled()
            args = spy.mostRecentCall.args[0]
            dependency.from.project = root1
            expect(args.from).toEqual dependency.from
            expect(args.to).toEqual dependency.to
