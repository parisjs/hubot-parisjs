# Search a beer using the brewerydb.com API
#
# beer search <query>

API_KEY = process.env.BREWERYDB_KEY;

module.exports = (robot) ->
  robot.respond /beer search (.+)/i, (msg) ->
    msg.http('http://api.brewerydb.com/v2/search').query({
       key: API_KEY,
       q: msg.match[1],
       type: 'beer'
    }).get() (err, res, body) ->
      return msg.send "error" if err
      body = JSON.parse(body)
      return msg.send body.errorMessage if body.status == 'failure'
      return msg.send "no beers found" if not body.data?
      msg.send formatBeer(beer) for beer in body.data

formatBeer = (beer) ->
    msg = []
    msg.push beer.name
    msg.push beer.abv + "%" if beer.abv?
    msg.push beer.style.name if beer.style? and beer.style.name?
    msg.join " - "
