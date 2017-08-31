# Description:
#   List AWS Billing Budgets
#
# Commands:
#   hubot budgets  - Displays forcasted usage details
AWS = require('aws-sdk')
JSON1 = require('parse-json')
ROUNDTO = require('round-to')
moment = require 'moment'
util   = require 'util'

module.exports = (robot) ->
  robot.respond /list budgets/i, (msg) ->
    arg1 = msg.match[1]
    msg.send "Listing available budgets for aws account..."

    budgets = new AWS.Budgets({apiVersion: '2016-10-20'})

    params = { AccountId: '291890047404' }
    budgets.describeBudgets params, (err, res) ->
      if err
        msg.send "Error: #{err}"
      else
        for budget in res.Budgets
          do (budget) ->
            msg.send "BudgetName: #{budget.BudgetName} BudgetLimit: #{budget.BudgetLimit.Amount} #{budget.BudgetLimit.Unit} "

