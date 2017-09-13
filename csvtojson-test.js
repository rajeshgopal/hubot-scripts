//const csvReadStream -- Readable stream for csv source
const csv=require('csvtojson')

var S3 = require('aws-sdk').S3,
    S3S = require('s3-streams');

let download = S3S.ReadStream(new S3(), {
      Bucket: 'rg-billing-test',
      Key: '291890047404-aws-billing-csv-2017-09.csv'
});

csv()
.fromStream(download)
.on('csv',(csvRow)=>{
    console.log(csvRow)
})
.on('done',(error)=>{
    console.log(error)
})
