//const csvReadStream -- Readable stream for csv source
const csv=require('fast-csv')

var S3 = require('aws-sdk').S3,
    S3S = require('s3-streams');

let download = S3S.ReadStream(new S3(), {
      Bucket: 'rg-billing-test',
      Key: '291890047404-aws-billing-csv-2017-09.csv'
});

var filedata = new Array();
var lastline = '';
csv
.fromStream(download, {headers : true})
.on('data',(csvRow)=>{
    filedata.push(csvRow);

    //console.log(csvRow);
})
    //console.log(filedata);
    //var lines = filedata.split('}{');
  //console.log(filedata.length)
    //lastline = lines[lines.length - 2];
    //console.log(lastline)

.on('end', (line)=>{
   console.log(line)
   console.log(filedata[filedata.length - 2].TotalCost)
});
