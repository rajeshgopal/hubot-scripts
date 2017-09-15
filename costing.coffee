# Description:
#   Extract AWS Billing Information from S3 Billing reports
#
# Commands:
#   hubot cost report  - Displays actual usage details
AWS = require 'aws-sdk'
S3 = require('aws-sdk').S3
CSV  = require 'fast-csv'

accountId = '291890047404'
bucket = 'rg-billing-test'
region = 'us-east-1'
filedata = []

S3S = require 's3-streams'

module.exports = (robot) ->
  robot.respond /cost report/i, (msg) ->
    arg1 = msg.match[1]
    #msg.send "Fetching #{arg1 || 'all (name is not provided)'}..."
    download = S3S.ReadStream(new S3,
      Bucket: 'rg-billing-test'
      Key: '291890047404-aws-billing-csv-2017-09.csv')

    CSV.fromStream(download, headers: true).on('data', (csvRow) ->
      filedata.push csvRow
    ).on 'end', (line) ->
      msg.send filedata[filedata.length - 2].TotalCost
