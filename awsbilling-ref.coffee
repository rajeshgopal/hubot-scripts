bind = require('bind')
csv = require('csv')
debug = require('debug')('aws-billing')
Ec2 = require('awssum-amazon-ec2').Ec2
knox = require('knox')
Dates = require('date-math')

###*
# Expose `AWSBilling`.
###

###*
# Create a new `AWSBilling` instance given the AWS `key`, `secret`,
# and S3 `bucket` and `region`.
#
# @param {String} accountId
# @param {String} key
# @param {String} secret
# @param {String} bucket
# @param {String} region
###

AWSBilling = (accountId, key, secret, bucket, region) ->
  if !(this instanceof AWSBilling)
    return new AWSBilling(accountId, key, secret, bucket, region)
  if !accountId
    throw new Error('AWS Billing requires a accountId.')
  if !key
    throw new Error('AWS Billing requires a key.')
  if !secret
    throw new Error('AWS Billing requires a secret.')
  if !bucket
    throw new Error('AWS Billing requires a bucket.')
  if !region
    throw new Error('AWS Billing requires a region.')
  @accountId = accountId
  @knox = knox.createClient(
    key: key
    secret: secret
    bucket: bucket)
  @ec2 = new Ec2(
    accessKeyId: key
    secretAccessKey: secret
    region: region)
  self = this
  bind.all this
  ->
    self.get.apply self, arguments

###*
# Pad a number with 0s.
#
# Credit: http://stackoverflow.com/questions/10073699/pad-a-number-with-leading-zeros-in-javascript
#
# @param {Number} n
# @param {Number} width
# @param {Number} z
# @return {String}
###

pad = (n, width, z) ->
  z = z or '0'
  n = n + ''
  if n.length >= width then n else new Array(width - (n.length) + 1).join(z) + n

module.exports = AWSBilling

###*
# Get the billing information.
#
# @param {Function} callback
###

AWSBilling::get = (callback) ->
  @products (err, products) ->
    if err
      return callback(err)
    total = 0.0
    Object.keys(products).forEach (product) ->
      total += products[product]
      return
    callback null,
      total: total
      start: Dates.month.floor(new Date)
      end: new Date
      products: products
    return
  return

###*
# Get the cost of AWS products
#
# @param {Function} callback
###

AWSBilling::products = (callback) ->
  accountId = @accountId.replace(/-/g, '')
  now = new Date
  file = accountId + '-aws-billing-csv-' + now.getFullYear() + '-' + pad(now.getMonth() + 1, 2) + '.csv'
  debug 'getting S3 file %s ..', file
  @knox.getFile file, (err, stream) ->
    if err
      return callback(err)
    debug 'got S3 stream ..'
    csv().from.stream(stream).to.array (data) ->
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
        return
      debug 'parsed AWS product costs'
      callback err, products
      return
    return
  return
