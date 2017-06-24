# Description:
#   It will tell you aws ec2 events.
#
# Commands:
#   maki awsのeventある？ - Reply files below the sctipts/ directory

child_process = require('child_process')
cron = require('cron').CronJob

module.exports = (robot) ->
  new cron '0 05 10 * * 1-5', () =>
    command = 'sh ./scripts/describe-events.sh'
    child_process.exec command, (error, stdout, stderr) ->
      robot.send {room: "#maki-bot"}, stdout
  , null, true, "Asia/Tokyo"

#module.exports = (robot) ->
  robot.respond /awsのeventある？/i, (msg) ->
    msg.send("ちょっとまってね...")
    child_process.exec 'sh ./scripts/describe-events.sh', (error, stdout, stderr) ->
      msg.send(stdout)
