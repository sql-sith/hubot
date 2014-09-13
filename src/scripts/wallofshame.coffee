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
  "Julio                12-Sep-2014  For encouraging me to contribute the wall of (F|Sh)ame; also,",
  "                                  because I needed another inductee for testing."
  ]

module.exports = (robot) ->
  robot.respond /\s*wall\s*of\s*(?:sh|f)ame.*?/i, (msg) ->
    msg.send '\n' + headers.join('\n') + '\n' + inductees.join('\n')
