#!/bin/sh

mkdir -p basic-rest-ear/keys
mkdir -p basic-rest-ear/messages/in
mkdir -p basic-rest-ear/messages/out

mkdir -p token-auth/keys
mkdir -p token-auth/messages/in
mkdir -p token-auth/messages/out

echo "This is my example message." > basic-rest-ear/messages/out/message.txt

# Generate the public/private key pair of User basic-rest-ear
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:3 -out basic-rest-ear/keys/privkey-basic-rest-ear.pem
openssl pkey -in basic-rest-ear/keys/privkey-basic-rest-ear.pem -pubout -out basic-rest-ear/keys/pubkey-basic-rest-ear.pem
cp basic-rest-ear/keys/pubkey-basic-rest-ear.pem token-auth/keys

# Generate the public/private key pair of User token-auth
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:3 -out token-auth/keys/privkey-token-auth.pem
openssl pkey -in token-auth/keys/privkey-token-auth.pem -pubout -out token-auth/keys/pubkey-token-auth.pem
cp token-auth/keys/pubkey-token-auth.pem basic-rest-ear/keys

# Create the digital signature, User basic-rest-ear sends to User token-auth
openssl dgst -sha256 -sign basic-rest-ear/keys/privkey-basic-rest-ear.pem -out token-auth/messages/in/signature.bin basic-rest-ear/messages/out/message.txt

# Encrypt the message, User basic-rest-ear sends to User token-auth
openssl pkeyutl -encrypt -in basic-rest-ear/messages/out/message.txt -pubin -inkey basic-rest-ear/keys/pubkey-token-auth.pem -out token-auth/messages/in/ciphertext.bin

# Decrypt the message, received by User token-auth from User basic-rest-ear
openssl pkeyutl -decrypt -in token-auth/messages/in/ciphertext.bin -inkey token-auth/keys/privkey-token-auth.pem -out token-auth/messages/in/received-message.txt

# Verify the signature, received by User token-auth from User basic-rest-ear
openssl dgst -sha256 -verify token-auth/keys/pubkey-basic-rest-ear.pem  -signature token-auth/messages/in/signature.bin token-auth/messages/in/received-message.txt