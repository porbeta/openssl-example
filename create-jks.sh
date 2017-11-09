#!/bin/sh

./sign-certificate.sh

rm -rf deploy-basic-rest-ear/basic.rest.example.com.p12
rm -rf deploy-basic-rest-ear/basic.rest.example.com.jks
rm -rf deploy-token-auth/token.auth.example.com.p12
rm -rf deploy-token-auth/token.auth.example.com.jks

winpty openssl pkcs12 -export \
	-in deploy-basic-rest-ear/basic.rest.example.com.cert.pem \
	-inkey deploy-basic-rest-ear/basic.rest.example.com.key.pem \
	-passin pass:secretpassword \
	-chain -CAfile deploy-basic-rest-ear/ca-chain.cert.pem \
	-name "basic.rest.example.com" \
	-out deploy-basic-rest-ear/basic.rest.example.com.p12 \
	-password pass:secretpassword

keytool -importkeystore \
	-deststorepass secretpassword \
	-destkeystore deploy-basic-rest-ear/basic.rest.example.com.jks \
	-srckeystore deploy-basic-rest-ear/basic.rest.example.com.p12 \
	-srcstorepass secretpassword \
	-srcstoretype PKCS12

keytool -v -list -keystore deploy-basic-rest-ear/basic.rest.example.com.jks -storepass secretpassword
	
winpty openssl pkcs12 -export \
	-in deploy-token-auth/token.auth.example.com.cert.pem \
	-inkey deploy-token-auth/token.auth.example.com.key.pem \
	-passin pass:secretpassword \
	-chain -CAfile deploy-token-auth/ca-chain.cert.pem \
	-name "token.auth.example.com" \
	-out deploy-token-auth/token.auth.example.com.p12 \
	-password pass:secretpassword

keytool -importkeystore \
	-deststorepass secretpassword \
	-destkeystore deploy-token-auth/token.auth.example.com.jks \
	-srckeystore deploy-token-auth/token.auth.example.com.p12 \
	-srcstorepass secretpassword \
	-srcstoretype PKCS12

keytool -v -list -keystore deploy-token-auth/token.auth.example.com.jks -storepass secretpassword