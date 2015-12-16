# Description:
#   Track issues JIRA-style entirely in Slack
#
# Dependencies:
#   "moment": "^2.10.6"
#   "uniquely": "0.0.2"
#
# Commands:
# 	@hubot - BUG: <title/description> <device/os/version>
# 	@hubot set status <issue id> '<status name>'
# 	@hubot list issues
# 	@hubot list issues '<status name>'
# 	@hubot issue detail <issue id>
#
# Author:
#   Phill Farrugia <me@phillfarrugia.com>

moment = require('moment')
unique = require('uniquely')

module.exports = (robot) ->

  if !robot.brain.data.issues
    robot.brain.data.issues = []
    robot.brain.save

  # empty issues
  emptyBrainRegex = /empty issues/i

  robot.respond emptyBrainRegex, (msg) ->
    robot.brain.data.issues = []
    robot.brain.save
    robot.messageRoom msg.message.room, "Issues list is now empty."

  # create new issue
  createIssueRegex = /(?:BUG:|bug:) (.*)/i

  robot.respond createIssueRegex, (msg) ->
    description = msg.match[1]
    reporter = msg.message.user.name
    date = moment().format('DD/MM/YYYY HH:mm')
    status = 'pending'
    issue = 
      'id': "PC-" + unique.random(4)
      'description': description
      'reporter': reporter
      'date': date
      'status': status

    robot.brain.data.issues.push issue
    robot.brain.save
    robot.messageRoom msg.message.room, "New issue created. Thanks for reporting it!"
    robot.messageRoom msg.message.room, ">>> *Id:* #{issue.id} \n*Description:* #{issue.description} \n*Reporter:* <@#{issue.reporter}> \n*Created:* #{issue.date} \n*Status:* [#{issue.status}]\n \n"

  # list all issues
  listAllIssuesRegex = /list issues$/i

  robot.respond listAllIssuesRegex, (msg) ->
    issues = robot.brain.data.issues
    logIssues issues, msg

  # list issues with specific status
  listSpecificIssueStatusRegex = /list issues (.*)/i

  robot.respond listSpecificIssueStatusRegex, (msg) ->
    status = msg.match[1]
    issues = robot.brain.data.issues
    matchingIssues = []
    for i of (issues or {})
      issue = issues[i]
      if issue.status == status
        matchingIssues.push issue
    logIssues matchingIssues, msg

  # set status for specific issue
  setIssueStatusRegex = /set status (PC-\w*)\s(.*)/i

  robot.respond setIssueStatusRegex, (msg) ->
    issueId = msg.match[1]
    status = msg.match[2]
    issues = robot.brain.data.issues
    matchingIssues = []
    for i of (issues or {})
      issue = issues[i]
      if issue.id == issueId
        issue.status = status
        matchingIssues.push issue
    if matchingIssues.length > 0
      for i of (matchingIssues or {})
        issue = matchingIssues[i]
        robot.messageRoom msg.message.room, "Updated issue status"
        robot.messageRoom msg.message.room, ">>> *Id:* #{issue.id} \n*Description:* #{issue.description} \n*Reporter:* <@#{issue.reporter}> \n*Created:* #{issue.date} \n*Status:* [#{issue.status}]\n \n"
      robot.brain.save
    else
      msg.send "No matching issues were found."

  # remove a specific issue
  removeIssueRegex = /remove issue (PC-\w*)/i

  robot.respond removeIssueRegex, (msg) ->
    issueId = msg.match[1]
    issues = robot.brain.data.issues
    matchingIssues = []
    for i of (issues or {})
      issue = issues[i]
      if issue.id == issueId
        robot.brain.data.issues.splice(i, 1)
        matchingIssues.push issue
        robot.brain.save
    if matchingIssues.length > 0
      for i of (matchingIssues or {})
        issue = matchingIssues[i]
        robot.messageRoom msg.message.room, "Removed issue"
        robot.messageRoom msg.message.room, ">>> *Id:* #{issue.id} \n*Description:* #{issue.description} \n*Reporter:* <@#{issue.reporter}> \n*Created:* #{issue.date} \n*Status:* [#{issue.status}]\n \n"
    else
      msg.send "No matching issues were found."

  # find a specific issue
  findIssueRegex = /find issue (PC-\w*)/i

  robot.respond findIssueRegex, (msg) ->
    issueId = msg.match[1]
    issues = robot.brain.data.issues
    matchingIssues = []
    for i of (issues or {})
      issue = issues[i]
      if issue.id == issueId
        matchingIssues.push issue
    logIssues matchingIssues, msg

  # log a list of issues
  logIssues = (issues, msg) ->
    if issues.length > 0
      for i of (issues or {})
        issue = issues[i]
        robot.messageRoom msg.message.room, ">>> *Id:* #{issue.id} \n*Description:* #{issue.description} \n*Reporter:* <@#{issue.reporter}> \n*Created:* #{issue.date} \n*Status:* [#{issue.status}]\n \n"
    else 
      robot.messageRoom msg.message.room, "There are no issues!"

