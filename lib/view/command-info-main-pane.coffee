module.exports =
  class MainInfoPane

    constructor: (command) ->
      @element = document.createElement 'div'
      @element.classList.add 'module'
      keys = document.createElement 'div'
      keys.innerHTML = '''
      <div class: 'text-padded'>Command</div>
      <div class: 'text-padded'>Working Directory</div>
      <div class: 'text-padded'>Shell</div>
      <div class: 'text-padded'>Wildcards</div>
      '''
      values = document.createElement 'div'
      for k in ['command', 'wd', 'shell', 'wildcards']
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command[k])
        values.appendChild value
      @element.appendChild keys
      @element.appendChild values
