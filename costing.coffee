# Description:
#   Extract AWS Billing Information from S3 Billing reports
#
# Commands:
#   hubot cost report  - Displays actual usage details
AWS = require 'aws-sdk'
S3 = require('aws-sdk').S3
CSV = require 'fast-csv'
accountId = '291890047404'
key = process.env.AWS_ACCESS_KEY_ID
secret = process.env.AWS_SECRET_ACCESS_KEY
bucket = 'rg-billing-test'
region = 'us-east-1'

#s3 = new AWS.S3()
S3S = require 's3-streams'

module.exports = (robot) ->
  robot.respond /cost report/i, (msg) ->
    arg1 = msg.match[1]
    msg.send "Fetching #{arg1 || 'all (name is not provided)'}..."
    download = S3S.ReadStream(new S3,
      Bucket: 'rg-billing-test'
      Key: '291890047404-aws-billing-csv-2017-09.csv')
    #console.log download
    #s3.getObject params, (err, data) ->
    #  if err
    #    msg.send  err, err.stack
    #  else
    #    msg.send data
    CSV.fromStream(download).toarray(data) ->
      products = {}
      productCol = data[0].indexOf('ProductCode') + 1
      costCol = data[0].indexOf('TotalCost')
      data.forEach (row) ->
        product = row[productCol].toLowerCase().replace(/amazon /, '').replace(/aws /, '')
        cost = parseFloat(row[costCol])
        if product and cost > 0
          if !products[product]
            products[product] = 0
          products[product] += cost
          msg.send products
  # successful response
