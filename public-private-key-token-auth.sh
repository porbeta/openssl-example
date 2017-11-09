#!/bin/sh

rm -rf basic-rest-ear
rm -rf token-auth

mkdir -p basic-rest-ear/keys
mkdir -p basic-rest-ear/messages/in
mkdir -p basic-rest-ear/messages/out

mkdir -p token-auth/keys
mkdir -p token-auth/messages/in
mkdir -p token-auth/messages/out

echo "This is my example message." > basic-rest-ear/messages/out/message.txt

# Generate the public/private key pair of User basic-rest-ear
openssl genrsa -aes256 -passout pass:secretpassword -out basic-rest-ear/keys/privkey-basic-rest-ear.pem 2048
openssl pkey -passin pass:secretpassword -in basic-rest-ear/keys/privkey-basic-rest-ear.pem -pubout -out basic-rest-ear/keys/pubkey-basic-rest-ear.pem
cp basic-rest-ear/keys/pubkey-basic-rest-ear.pem token-auth/keys

# Generate the public/private key pair of User token-auth
openssl genrsa -aes256 -passout pass:secretpassword -out token-auth/keys/privkey-token-auth.pem 2048
openssl pkey -passin pass:secretpassword -in token-auth/keys/privkey-token-auth.pem -pubout -out token-auth/keys/pubkey-token-auth.pem
cp token-auth/keys/pubkey-token-auth.pem basic-rest-ear/keys

# Create the digital signature, User basic-rest-ear sends to User token-auth
openssl dgst -sha256 -sign basic-rest-ear/keys/privkey-basic-rest-ear.pem -passin pass:secretpassword -out token-auth/messages/in/signature.bin basic-rest-ear/messages/out/message.txt

# Encrypt the message, User basic-rest-ear sends to User token-auth
openssl pkeyutl -encrypt -in basic-rest-ear/messages/out/message.txt -pubin -inkey basic-rest-ear/keys/pubkey-token-auth.pem -out token-auth/messages/in/ciphertext.bin

# Decrypt the message, received by User token-auth from User basic-rest-ear
openssl pkeyutl -decrypt -in token-auth/messages/in/ciphertext.bin -inkey token-auth/keys/privkey-token-auth.pem -passin pass:secretpassword -out token-auth/messages/in/received-message.txt

# # Verify the signature, received by User token-auth from User basic-rest-ear
openssl dgst -sha256 -verify token-auth/keys/pubkey-basic-rest-ear.pem  -signature token-auth/messages/in/signature.bin token-auth/messages/in/received-message.txt