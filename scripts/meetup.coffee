# Allows Hubot to show info on meetups
#
# next meetup
# who spoke at parisjs?

parisjs = require('parisjs-website')

get_meetups = (msg, callback) ->
  msg
    .http('http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D%27https%3A%2F%2Fwww.eventbrite.com%2Fxml%2Forganizer_list_events%3Fapp_key%3DOTlkMWFkODNjYThl%26id%3D856075%27&format=json&diagnostics=true')
    .headers
      'Accept-Language': 'en-us,en;q=0.5',
      'Accept-Charset': 'utf-8'
    .get() (err, res, body) ->
      result = JSON.parse(body)
      if result.query.count > 0
        events = result.query.results.events.event
        callback(events)
      else
        msg.send "sorry error"

format_meetup = (meetup) ->
  "#{meetup.title} @ #{meetup.venue.name} - #{meetup.start_date} - #{meetup.num_attendee_rows} attendees - #{meetup.url}"

module.exports = (robot) ->
  robot.respond /next meetup/i, (msg) ->
    get_meetups msg, (events) ->
      next = events[events.length - 1]
      if next.status == 'Completed'
        msg.send "sorry no meetup scheduled yet"
      else
        msg.send format_meetup(next)

  robot.respond /(latest|previous) meetup/i, (msg) ->
    get_meetups msg, (events) ->
      latest = events[events.length - 1]
      latest = events[events.length - 2] if latest.status != 'Completed'
      msg.send format_meetup(latest)

  robot.respond /who spoke at (parisjs|meetup) ([1-9]+)?/i, (msg) ->
    parisjs.parseMeetups 'http://parisjs.org/', (meetups) ->
      meetups = JSON.parse(meetups)
      num = meetups.length - msg.match[2]
      meetup = meetups[num]
      return msg.send("sorry this meetup doesn't exists") if not meetup
      msg.send((authors talk for talk in meetup.talks).join(", "))

authors = (talk) ->
  (author.name for author in talk.authors).join(', ')
