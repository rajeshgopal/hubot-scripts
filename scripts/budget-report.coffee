# Description:
#   Retrieves AWS Budget Details
#
# Commands:
#   hubot cost budget report  - Retrieves available budget reports from AWS account
AWS = require('aws-sdk')
ROUNDTO = require('round-to')

accountId = process.env.AWS_ACCOUNT_ID

module.exports = (robot) ->
  robot.respond /cost (.*)/i, (msg) ->
    arg1 = msg.match[1]
    if arg1 == 'budget report'
      msg.send "Fetching Budget reports..."
      budgets = new AWS.Budgets({apiVersion: '2016-10-20'})
    
      params = { AccountId: "#{accountId}" }
      budgets.describeBudgets params, (err, res) ->
        if err
          msg.send "Error: #{err}"
        else
          for budget in res.Budgets
            do (budget) ->
              budgettype = budget.BudgetType
              budgetname = budget.BudgetName
              limit = ROUNDTO(parseInt(budget.BudgetLimit.Amount, 10), 2)
              usage = ROUNDTO(parseInt(budget.CalculatedSpend.ActualSpend.Amount, 10), 2)
              unit = budget.CalculatedSpend.ActualSpend.Unit
              msg.send "BudgetName: #{budgetname}\n Limit: #{limit} #{unit}  CurrentUsage: #{usage} #{unit} "

