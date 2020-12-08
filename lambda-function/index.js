'use strict';
var AWS = require("aws-sdk");
const httpAwsEs = require('http-aws-es');
const elasticsearch = require('elasticsearch');

const client = new elasticsearch.Client({
    host: process.env.ES_HOST,
    connectionClass: httpAwsEs,
    amazonES: {
        region: process.env.ES_REGION,
        credentials: new AWS.EnvironmentCredentials('AWS')
    }
});

exports.handler = (event, context, callback) => {

    event.Records.forEach((record) => {
        console.log('Stream record: ', JSON.stringify(record, null, 2));

        if (record.eventName === 'INSERT') {
            var rawData = record.dynamodb.NewImage;
            client.index({
                index: 'transactions',
                // type: 'lambda-type',
                body: {
                    accountId: rawData.accountId.N,
                    shortDescription: rawData.shortDescription.S,
                    amount: rawData.amount.N,
                    userId: rawData.userId.N,
                    transactionId: rawData.transactionId.N
                }
            });
        }
    });
    callback(null, `Successfully processed ${event.Records.length} records.`);
};