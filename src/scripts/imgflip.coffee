# Description:
#   Integrates with imgflip
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_IMGFLIP_USERNAME
#   HUBOT_IMGFLIP_PASSWORD
#
# Commands:
#   hubot add meme /<meme regex with two groups>/ <templateId>
#   hubot remove meme /<meme regex>/
#   hubot list memes
#   hubot (Oh|You) <text> (Please|Tell) <text> - Willy Wonka
#   hubot khanify <text> - TEEEEEEEEEEEEEEEEEXT!
#
# Author:
#   skalnik, andrewkatz, julio

module.exports = (robot) ->

  robot.respond /remove meme \/(.+)\//i, (msg) ->
    setUpMemes robot.brain
    delete robot.brain.data.imgflipMemes[msg.match[1]]
    msg.reply khanify("Meme deleted")

  robot.respond /(.*)/i, (msg) ->
    setUpMemes robot.brain
    for reg, meme of robot.brain.data.imgflipMemes
      regex = new RegExp(meme.regex.toString(), "i")
      continue unless regex.test(msg.match[1])
      matches = msg.match[1].match regex
      memeResponder(msg, matches, meme)

  robot.respond /add meme \/(.+)\/\s+(.+)/i, (msg) ->
    setUpMemes robot.brain
    console.log msg.match[1]
    console.log parseInt(msg.match[2])
    rememberMeme robot.brain, msg.match[1], parseInt(msg.match[2])
    msg.reply khanify("Meme added")

  robot.respond /list memes/i, (msg) ->
    setUpMemes robot.brain
    memesList = for reg, meme of robot.brain.data.imgflipMemes
      meme.regex
    msg.reply memesList.join('\n')

  robot.respond /k(?:ha|ah)nify (.*)/i, (msg) ->
    memeGenerator msg, 2743696, "", khanify(msg.match[1]), [], (url) ->
      msg.send url

  robot.respond /((Oh|You) .*) ((Please|Tell) .*)/i, (msg) ->
    memeGenerator msg, 7541968, msg.match[1], msg.match[3], [], (url) ->
      msg.send url

importMemesFromUrl = (robot, msg, url) ->
  console.log url
  msg.http(url).get() (err, res, body) ->
    importedData = JSON.parse(body)
    for regex, meme of importedData
      robot.brain.data.imgflipMemes[regex] = meme
    msg.reply khanify("Import successful")


setUpMemes = (brain) ->
  unless brain.data.imgflipMemes?
    brain.data.imgflipMemes = {}
    rememberMeme brain, '(Y U NO) (.+)', 61527
    rememberMeme brain, '(I DON\'?T ALWAYS .*) (BUT WHEN I DO,? .*)', 61532
    rememberMeme brain, '(.*)(O\\s?RLY\\??.*)', 11603731
    rememberMeme brain, '(.*)(SUCCESS|NAILED IT.*)', 61544
    rememberMeme brain, '(.*) (ALL the .*)', 61533
    rememberMeme brain, '(.*) (\\w+\\sTOO DAMN .*)', 61580
    rememberMeme brain, '(GOOD NEWS EVERYONE[,.!]?) (.*)', 7163250
    rememberMeme brain, '(NOT SURE IF .*) (OR .*)', 61520
    rememberMeme brain, '(YO DAWG .*) (SO .*)', 101716
    rememberMeme brain, '(ALL YOUR .*) (ARE BELONG TO US)', 4503404
    rememberMeme brain, '(.*) (FUCK YOU)', 165248
    rememberMeme brain, '(.*) (You\'?re gonna have a bad time)', 100951
    rememberMeme brain, '(one does not simply) (.*)', 61579
    rememberMeme brain, 'grumpy cat (.*),(.*)', 405658
    rememberMeme brain, '(.*) (aliens)', 101470

rememberMeme = (brain, regex, templateId) ->
    meme =
      regex: regex
      templateId: templateId
    brain.data.imgflipMemes[regex] = meme

memeResponder = (msg, matches, meme) ->
  msg.reply "Generating your meme..."
  memeGenerator msg, meme.templateId, matches[1], matches[2], [], (url) ->
    msg.send url

memeGenerator = (msg, templateId, text0, text1, boxes, callback) ->
  # username = process.env.HUBOT_IMGFLIP_USERNAME
  # password = process.env.HUBOT_IMGFLIP_PASSWORD
  username = "j...s"
  password = "s...7"
  preferredDimensions = process.env.HUBOT_MEMEGEN_DIMENSIONS
  unless username? and password?
    msg.send "imgflip account isn't setup. Sign up at http://imgflip.com"
    msg.send "Then ensure the HUBOT_IMFGLIP_USERNAME and HUBOT_IMGFLIP_PASSWORD environment variables are set"
    return

  queryParams =
    username: username,
    password: password,
    template_id: templateId,
    text0: text0,
    text1: text1

  queryParams['boxes'] = boxes if boxes?

  msg.http("https://api.imgflip.com/caption_image")
    .query(queryParams).post() (err, res, body) ->
      if err
        msg.reply "I got an exception trying to contact imgflip:", inspect(err)
        return

      jsonBody = JSON.parse(body)
      success = jsonBody.success
      errorMessage = jsonBody.error_message
      data = jsonBody.data

      if not success
        msg.reply "Request to imgflip failed: \"#{errorMessage}.\""
        return

      img = data?.url

      unless img
        msg.reply "I got back weird results from imgflip. Expected an image URL, but couldn't find it in the result. Here's what I got:", inspect(jsonBody)
        return

      callback img

khanify = (msg) ->
  msg = msg.toUpperCase()
  vowels = [ 'A', 'E', 'I', 'O', 'U' ]
  index = -1
  for v in vowels when msg.lastIndexOf(v) > index
    index = msg.lastIndexOf(v)
  "#{msg.slice 0, index}#{Array(10).join msg.charAt(index)}#{msg.slice index}!!!!!"
