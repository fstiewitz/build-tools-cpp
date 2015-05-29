describe 'Console View', ->
  [workspaceElement, activationPromise, view] = []

  execute = (callback) ->
    atom.commands.dispatch(workspaceElement, 'build-tools-cpp:show')
    waitsForPromise -> activationPromise
    runs callback

  describe 'On build-tools-cpp:show', ->
    it 'shows a header without a console', ->
      workspaceElement = atom.views.getView(atom.workspace)
      activationPromise = atom.packages.activatePackage('build-tools-cpp')
      execute ->
        view = workspaceElement.getModel().getBottomPanels()[0].getItem()
        expect(view.hasClass('console')).toBe true
        expect(view.find('.output').hasClass('hidden')).toBe true

    describe 'When :setHeader', ->
      it 'sets the header', ->
        execute ->
          view = workspaceElement.getModel().getBottomPanels()[0].getItem()
          expect(view.find('.name').html()).toBe ''
          view.setHeader 'Test'
          expect(view.find('.name').html()).toBe 'Test'

    describe 'When :printLine', ->
      it 'prints a line', ->
        execute ->
          view = workspaceElement.getModel().getBottomPanels()[0].getItem()
          expect(view.find('.output').html()).toBe ''
          expect(view.find('.output').hasClass('hidden')).toBe true
          view.printLine 'Test'
          expect(view.find('.output').html()).toBe 'Test'
          expect(view.find('.output').hasClass('hidden')).toBe false
