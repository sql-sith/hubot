# Description:
#   Displays the #messed-up "Wall of Fame/Shame."
#
# Commands:
#   hubot wall of shame - Display the #messed-up "Wall of Fame/Shame."
#   hubot wall of fame - Display the #messed-up "Wall of Fame/Shame."

headers = [
  "Name                 Inducted     Reason",
  "-------------------- ------------ ---------------------------------------------------------------"
  ]

inductees = [
  "Viju Thomas          12-Sep-2014  For posting \"Finally! Light snow in Denver.\" In September.",
  "Nou Luck             25-Sep-2014  Because varchar(10) != CSV."
  ]

# The ``` delimiters below are an attempt to get poor-man's (pre)formatting for the msg:
module.exports = (robot) ->
  robot.respond /\s*wall\s*of\s*(?:sh|f)ame.*?/i, (msg) ->
    msg.send '```\n' + headers.join('\n') + '\n' + inductees.join('\n') + '```'
