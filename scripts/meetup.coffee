# Allows Hubot to show info on meetups
#
# next meetup
# previous/latest meetup
# who spoke at parisjs?
# who spoke about javascript ?

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

  robot.respond /who spoke at (parisjs|meetup) ([0-9]+)?/i, (msg) ->
    parisjs.parseMeetups 'http://parisjs.org/', (meetups) ->
      meetups = JSON.parse(meetups)
      num = meetups.length - msg.match[2]
      meetup = meetups[num]
      return msg.send("sorry this meetup doesn't exists") if not meetup
      msg.send((authors talk for talk in meetup.talks).join(", "))
      
  robot.respond /who spoke about ([\w]+) ?/i, (msg) ->
    console.log('who spoke about')
    parisjs.parseMeetups 'http://parisjs.org/', (meetups) ->
      meetups = JSON.parse(meetups)
      has_been_spoken_once = false
      has_been_spoken_each = (spoken_in(meetup, msg) for meetup in meetups)
      (has_been_spoken_once = has_been_spoken_once || spoken) for spoken in has_been_spoken_each
      msg.send ('No one yet spoke about ' + msg.match[1] + '. You might be the first : http://goo.gl/5l1wg') if not has_been_spoken_once
        

authors = (talk) ->
  (author.name for author in talk.authors).join(', ')

links = (talk, type) ->
  if talk[type] && talk[type].length > 0
    return talk[type].join(' ') + ' ' 
  else
    return ''
  
spoken_in = (meetup, msg) ->
  keyword = msg.match[1].toLowerCase()
  talks = (talk for talk in meetup.talks when talk.title.toLowerCase().indexOf(keyword) != -1)
  
  if talks
    msg.send(authors(talk) + ' spoke about ' + msg.match[1] + ' in : "' + talk.title + '" on ' + meetup.title + '. See more on ' + links(talk, 'slides') + links(talk, 'videos') + links(talk, 'projects')) for talk in talks

  return talks.length > 0
