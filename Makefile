include ./key.mk
default:
	@make ssl
	@make cp
	@make reset
init:
	#GOARCH=amd64 GOOS=linux go build -o bin/certstrap-${BUILD_TAG}-linux-amd64 ${REPO_PATH}
	GOARCH=amd64 GOOS=darwin go build -o bin/certstrap-darwin-amd64 .
	#GOARCH=amd64 GOOS=windows go build -o bin/certstrap-${BUILD_TAG}-windows-amd64 ${REPO_PATH}
git:

ssl:
	rm -rf out
	#ca
	./bin/certstrap-darwin-amd64 init --passphrase="$(CApassphrase)" --expires "100 year" --organization "zito infotech .LTD" --common-name "zito"
	
	#server
	./bin/certstrap-darwin-amd64 request-cert  --passphrase="" --common-name "grpc.apiatm.com" --domain "grpc.apiatm.com,*.grpc.apiatm.com"
	./bin/certstrap-darwin-amd64 sign --expires "100 year"  --passphrase="$(CApassphrase)" --CA zito "grpc.apiatm.com"
	#client
	./bin/certstrap-darwin-amd64 request-cert --passphrase="" --common-name "client-1010101"
	./bin/certstrap-darwin-amd64 sign --passphrase="$(CApassphrase)" --expires "100 year" --CA zito "client-1010101" 
cp:
	-rm -rf $(GOPATH)/src/github.com/hkloudou/nginx-docker/tmp/nginx/ssl/grpc.apiatm.com_ca.crt
	-rm -rf $(GOPATH)/src/github.com/hkloudou/nginx-docker/tmp/nginx/ssl/grpc.apiatm.com.crt
	-rm -rf $(GOPATH)/src/github.com/hkloudou/nginx-docker/tmp/nginx/ssl/grpc.apiatm.com.key
	cp out/zito.crt $(GOPATH)/src/github.com/hkloudou/nginx-docker/tmp/nginx/ssl/grpc.apiatm.com_ca.crt
	cp out/grpc.apiatm.com.crt $(GOPATH)/src/github.com/hkloudou/nginx-docker/tmp/nginx/ssl/grpc.apiatm.com.crt
	cp out/grpc.apiatm.com.key $(GOPATH)/src/github.com/hkloudou/nginx-docker/tmp/nginx/ssl/grpc.apiatm.com.key
reset:
	cd $(GOPATH)/src/github.com/hkloudou/nginx-docker/ && make up