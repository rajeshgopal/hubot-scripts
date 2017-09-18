# Description:
#   Extract AWS Billing Information from S3 Billing reports
#
# Commands:
#   mbot cost report  - Retrieves usage details for the current month 
AWS = require 'aws-sdk'
S3 = require('aws-sdk').S3
CSV  = require 'fast-csv'

date = new Date
month = d.getMonth()
accountId = process.env.AWS_ACCOUNT_ID
bucket = process.env.AWS_S3_BILLING_BUCKET
region = 'us-east-1'
filedata = []

S3S = require 's3-streams'

module.exports = (robot) ->
  robot.respond /cost report/i, (msg) ->
    arg1 = msg.match[1]
    #msg.send "Fetching #{arg1 || 'all (name is not provided)'}..."
    download = S3S.ReadStream(new S3,
      Bucket: "#{bucket}"
      Key: "#{accountId}-aws-billing-csv-#{year}-#{month}.csv")

    CSV.fromStream(download, headers: true).on('data', (csvRow) ->
      filedata.push csvRow
    ).on 'end', (line) ->
      msg.send filedata[filedata.length - 2].TotalCost filedata[filedata.length - 2].CurrencyCode
      msg.send fieldata[filedata.length].ItemDescription
