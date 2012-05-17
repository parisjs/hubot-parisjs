# Correct misspelled paris.js
#

module.exports = (robot) ->
  robot.hear /paris js/i, (msg) ->
   msg.send("#{msg.message.user.name}: you shoud write 'paris.js' instead of '#{msg.match[0]}'.")
