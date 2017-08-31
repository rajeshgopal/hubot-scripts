# Description:
#   Extract AWS Billing Information
#
# Commands:
#   hubot billing  - Displays forcasted usage details
#   hubot billing  - Displays actual usage details 
AWS = require('aws-sdk')
JSON1 = require('parse-json')
ROUNDTO = require('round-to')
moment = require 'moment'
util   = require 'util'

module.exports = (robot) ->
  robot.respond /(billing .*)$/i, (msg) ->
    arg1 = msg.match[1]
    msg.send "Fetching #{arg1 || 'all (name is not provided)'}..."

    budgets = new AWS.Budgets({apiVersion: '2016-10-20'})

    params = { AccountId: '291890047404' }
    budgets.describeBudgets params, (err, res) ->
      if err
        msg.send "Error: #{err}"
      else
        for budget in res.Budgets
          do (budget) ->
            budgettype = budget.BudgetType
            limit = ROUNDTO(parseInt(budget.BudgetLimit.Amount, 10), 2)
            usage = ROUNDTO(parseInt(budget.CalculatedSpend.ActualSpend.Amount, 10), 2)
            unit = budget.CalculatedSpend.ActualSpend.Unit
            msg.send "BudgetType: #{budgettype} Limit: #{limit} #{unit}  CurrentUsage: #{usage} #{unit} "

