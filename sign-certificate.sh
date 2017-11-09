#!/bin/sh

./openssl-ca-example.sh
./public-private-key-token-auth.sh

cwd=$(pwd)

rm -rf $cwd/deploy-token-auth
rm -rf $cwd/deploy-basic-rest-ear

# Generate certificate for token-auth

cp $cwd/token-auth/keys/privkey-token-auth.pem $cwd/root/ca/intermediate/private/token.auth.example.com.key.pem

cd $cwd/root/ca

openssl req \
	  -new \
	  -key intermediate/private/token.auth.example.com.key.pem \
	  -passin pass:secretpassword \
      -out intermediate/csr/token.auth.example.com.csr.pem \
	  -subj "//CN=token.auth.example.com\O=OpenSSL Example Ltd\L=Baltimore\S=Maryland\C=US"

winpty openssl ca -batch -config intermediate/openssl.cnf -extensions server_cert \
      -days 375 -notext -md sha256 \
      -in intermediate/csr/token.auth.example.com.csr.pem \
	  -passin pass:secretpassword \
      -out intermediate/certs/token.auth.example.com.cert.pem
	  
openssl x509 -noout -text -in intermediate/certs/token.auth.example.com.cert.pem


echo ""
echo "Verifying with token.auth.example.com CA-Cert:"

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem intermediate/certs/token.auth.example.com.cert.pem

cd $cwd

mkdir -p $cwd/deploy-token-auth

cp $cwd/root/ca/intermediate/private/token.auth.example.com.key.pem $cwd/deploy-token-auth
cp $cwd/root/ca/intermediate/certs/token.auth.example.com.cert.pem $cwd/deploy-token-auth
cp $cwd/root/ca/intermediate/certs/ca-chain.cert.pem $cwd/deploy-token-auth
cp $cwd/token-auth/keys/pubkey-token-auth.pem $cwd/deploy-token-auth/token.auth.example.com.key.pub.pem


# Generate certificate for basic-rest-ear

cp $cwd/basic-rest-ear/keys/privkey-basic-rest-ear.pem $cwd/root/ca/intermediate/private/basic.rest.example.com.key.pem

cd $cwd/root/ca

openssl req \
	  -new \
	  -key intermediate/private/basic.rest.example.com.key.pem \
	  -passin pass:secretpassword \
      -out intermediate/csr/basic.rest.example.com.csr.pem \
	  -subj "//CN=basic.rest.example.com\O=OpenSSL Example Ltd\L=Baltimore\S=Maryland\C=US"

winpty openssl ca -batch -config intermediate/openssl.cnf -extensions server_cert \
      -days 375 -notext -md sha256 \
      -in intermediate/csr/basic.rest.example.com.csr.pem \
	  -passin pass:secretpassword \
      -out intermediate/certs/basic.rest.example.com.cert.pem
	  
openssl x509 -noout -text -in intermediate/certs/basic.rest.example.com.cert.pem


echo ""
echo "Verifying basic.rest.example.com with CA-Cert:"

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem intermediate/certs/basic.rest.example.com.cert.pem

cd $cwd

mkdir -p $cwd/deploy-basic-rest-ear

cp $cwd/root/ca/intermediate/private/basic.rest.example.com.key.pem $cwd/deploy-basic-rest-ear
cp $cwd/root/ca/intermediate/certs/basic.rest.example.com.cert.pem $cwd/deploy-basic-rest-ear
cp $cwd/root/ca/intermediate/certs/ca-chain.cert.pem $cwd/deploy-basic-rest-ear
cp $cwd/basic-rest-ear/keys/pubkey-basic-rest-ear.pem $cwd/deploy-basic-rest-ear/basic.rest.example.com.key.pub.pem