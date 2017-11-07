#!/bin/sh

rm -rf root

cwd=$(pwd)

root_dir=$cwd/root/ca
intermediate_dir=$root_dir/intermediate

echo "Current directory: $cwd"

mkdir -p root/ca
mkdir -p root/ca/intermediate

cp openssl-root.cnf root/ca/openssl.cnf
cp openssl-intermediate.cnf root/ca/intermediate/openssl.cnf

sed -i "s,<dir>,$root_dir,g" root/ca/openssl.cnf
sed -i "s,<dir>,$intermediate_dir,g" root/ca/intermediate/openssl.cnf


cd $cwd/root/ca

mkdir -p certs crl newcerts private
> index.txt
echo 1000 > serial

# Create the root key and certificate
openssl req \
	-nodes \
	-newkey rsa:4096 \
    -new -x509 -days 7300 -sha256 -extensions v3_ca \
    -subj "//OU=OpenSSL Root CA\OU=Certification Authorities\O=OpenSSL Example Ltd\C=US" \
    -keyout private/ca.key.pem \
    -out certs/ca.cert.pem
	
openssl x509 -noout -text -in certs/ca.cert.pem

cd $cwd/root/ca/intermediate

mkdir certs crl csr newcerts private
> index.txt
echo 1000 > serial
echo 1000 > crlnumber

# Create the intermediate key and certificate signing request
openssl req \
	-nodes \
    -newkey rsa:4096 \
    -subj "//OU=OpenSSL Example Certification Authority\OU=SSA\O=OpenSSL Example Ltd\C=US" \
    -keyout private/intermediate.key.pem \
    -out csr/intermediate.csr.pem

	
cd $cwd/root/ca	

# Create the intermediate certificate
winpty openssl ca -batch -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem

openssl verify -CAfile certs/ca.cert.pem intermediate/certs/intermediate.cert.pem

cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem