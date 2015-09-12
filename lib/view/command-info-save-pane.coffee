module.exports =
  class SaveInfoPane

    constructor: (command) ->
      @element = document.createElement 'div'
      @element.classList.add 'module'
      keys = document.createElement 'div'
      keys.innerHTML = '''
      <div class: 'text-padded'>Save modified</div>
      '''
      values = document.createElement 'div'
      value = document.createElement 'div'
      value.classList.add 'text-padded'
      value.innerText = String(command.save_all)
      values.appendChild value
      @element.appendChild keys
      @element.appendChild values
