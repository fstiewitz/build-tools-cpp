highlight_translation =
  'nh': 'No highlighting'
  'ha': 'Highlight all'
  'ht': 'Highlight tags'

{profiles} = require '../profiles/profiles'

module.exports =
  class ProfileInfoPane

    constructor: (command) ->
      @element = document.createElement 'div'
      @element.classList.add 'module'
      keys = document.createElement 'div'
      keys.innerHTML = '''
      <div class: 'text-padded'>stdout highlighting:</div>
      <div class: 'text-padded'>stderr highlighting:</div>
      '''
      values = document.createElement 'div'
      for k in ['stdout', 'stderr']
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        if command[k].highlighting isnt 'hc'
          value.innerText = highlight_translation[command[k].highlighting]
        else
          value.innerText = String(profiles[command[k].profile]?.profile_name)
        values.appendChild value
      @element.appendChild keys
      @element.appendChild values
