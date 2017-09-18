# Description:
#   Extract AWS Billing Information from Billing reports stored in S3
#
# Commands:
#   mbot cost report  - Retrieves current month total usage cost of an AWS accoun
AWS = require 'aws-sdk'
S3 = require('aws-sdk').S3
CSV  = require 'fast-csv'
S3S = require 's3-streams'

#Get month and Year
date = new Date
m = date.getMonth() + 1
month = if m < 10 then '0'+m else m
year = date.getFullYear()

#Read AWS account details from ENV
accountId = process.env.AWS_ACCOUNT_ID
bucket = process.env.AWS_S3_BILLING_BUCKET
region = process.env.HUBOT_AWS_REGION

filedata = []

module.exports = (robot) ->
  robot.respond /cost report/i, (msg) ->
    msg.send "Fetching cost report for account #{accountId}..."

    download = S3S.ReadStream(new S3,
      Bucket: "#{bucket}"
      Key: "#{accountId}-aws-billing-csv-#{year}-#{month}.csv").on 'error', (err) ->
        msg.send 'Error occured while downloading report from S3'
        return

    CSV.fromStream(download, headers: true).on('data', (csvRow) ->
      filedata.push csvRow
    ).on 'end', () ->
     msg.send filedata[filedata.length - 2].TotalCost + filedata[filedata.length - 2].CurrencyCode
