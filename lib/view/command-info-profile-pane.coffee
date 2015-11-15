highlight_translation =
  'nh': 'No highlighting'
  'ha': 'Highlight all'
  'ht': 'Highlight tags'

ansi_translation =
  'ignore': 'Ignore ANSI Color Codes'
  'remove': 'Remove ANSI Color Codes'
  'parse': 'Parse ANSI Color Codes'

{profiles} = require '../profiles/profiles'

module.exports =
  class ProfileInfoPane

    constructor: (command) ->
      @element = document.createElement 'div'
      @element.classList.add 'module'
      keys = document.createElement 'div'
      keys.innerHTML = '''
      <div class="text-padded">stdout highlighting:</div>
      <div class="text-padded">stderr highlighting:</div>
      '''
      values = document.createElement 'div'
      if command.stdout.pty
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        if command['stdout'].highlighting is 'hc'
          value.innerText = String(profiles[command['stdout'].profile]?.profile_name)
        else if command['stdout'].highlighting is 'hr'
          value.innerText = command['stdout'].regex
        else if command['stdout'].highlighting is 'nh'
          value.innerText = "No highlighting - #{ansi_translation[command['stdout'].ansi_option ? 'ignore']}"
        else
          value.innerText = highlight_translation[command['stdout'].highlighting]
        values.appendChild value
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = 'Disabled (pty enabled)'
        values.appendChild value
      else
        for k in ['stdout', 'stderr']
          value = document.createElement 'div'
          value.classList.add 'text-padded'
          if command[k].highlighting is 'hc'
            value.innerText = String(profiles[command[k].profile]?.profile_name)
          else if command[k].highlighting is 'hr'
            value.innerText = command[k].regex
          else if command[k].highlighting is 'nh'
            value.innerText = "No highlighting - #{ansi_translation[command[k].ansi_option ? 'ignore']}"
          else
            value.innerText = highlight_translation[command[k].highlighting]
          values.appendChild value
      @element.appendChild keys
      @element.appendChild values
