This is a terraform project to bild next env:

DynomDB table with stream -> Lambda listening to the stream -> Elasticsearch service

## Run rollout of the infrastructure
* configure AWS console locally
* configure params in variables.tf if needed
* run `terraform init` and then `terraform apply`
* type yes

## Test the environment setup
put row into dynamodb table:
```
aws dynamodb put-item \
--table-name UsersTransactions \
--item userId={N=3},transactionId={N=51},accountId={N=3},amount={N=11},shortDescription={S="Final mega test 2"} --profile relaximus
``` 

in a few seconds check the kibana interface by url, which could be found the output, like this:
```
es_kibana_host = search-dynamostream-ph7dni5uop7gcepdpxhhhyar3i.eu-central-1.es.amazonaws.com/_plugin/kibana/
```