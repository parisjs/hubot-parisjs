# Allows Hubot to show info on meetups
#
# next meetup
module.exports = (robot) ->
  robot.respond /(next meetup)/i, (msg) ->
    msg
      .http('http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D%27https%3A%2F%2Fwww.eventbrite.com%2Fxml%2Forganizer_list_events%3Fapp_key%3DOTlkMWFkODNjYThl%26id%3D856075%27&format=json&diagnostics=true')
      .headers
        'Accept-Language': 'en-us,en;q=0.5',
        'Accept-Charset': 'utf-8'
      .get() (err, res, body) ->
        result = JSON.parse(body)
        if result.query.count > 0
          events = result.query.results.events.event
          next = events[events.length - 1]
          msg.send "#{next.title} @ #{next.venue.name} - #{next.start_date} - #{next.num_attendee_rows} attendees - #{next.url}"
        else
          msg.send "sorry error"
