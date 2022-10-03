AWS_MOCK_NAME=awsmock
S3_PORT=4572
SQS_PORT=4576
AWS_MOCK_UI_PORT=8082

aws_init() {
    echo "** Docker building fresh AWSMOCK image **"
    docker build -f ./data/Dockerfile_awsmock -t awsmock_app .
}

aws_exec() {
  container_check_and_remove $AWS_MOCK_NAME

  echo "** Docker running fresh $AWS_MOCK_NAME container from localstack/localstack image **"
  docker run $DOCKER_RUN_REFERENCE \
    -p $S3_PORT:4572 \
    -p $SQS_PORT:4576 \
    -p $AWS_MOCK_UI_PORT:8082 \
    --restart=unless-stopped \
    --network=devnet \
    --name=$AWS_MOCK_NAME -e PORT_WEB_UI=8082 awsmock_app 

  echo Waiting 10 seconds for startup...
  sleep 10
  echo waiting until the service is started...
  curl --retry-delay 5 --retry 12 "http://localhost:$S3_PORT/" 
  docker logs $AWS_MOCK_NAME
  echo Adding bucket \'e-folder\' to S3...
  curl -X PUT -H "Content-Type: application/x-www-form-urlencoded" -H "Authorization: AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20160706/us-east-1/execute-api/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=a2b5acc994b59b0982619b8938d353b82a01e85788ade0b8433025e2d60b0fb1" -H "Cache-Control: no-cache" -H "Postman-Token: d7f3f85f-2b9d-6d64-4f11-e8906acac1a0" -d '' "http://localhost:4572/e-folder" 
}

aws_clean() {
    echo "aws_clean ++"
}