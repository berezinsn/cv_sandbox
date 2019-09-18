#!/bin/bash

if [ -z $* ]
then
echo "No options found! Please start script with -d (deploy), -e (erase) keys"
exit 1
fi

# export variable GP (GCP project name)
TF_VAR_GP=consul-vault-infra
export TF_VAR_GP

# export region value 
TF_VAR_REG=europe-west1
export TF_VAR_REG

# export zone value
TF_VAR_ZONE=europe-west1-b
export TF_VAR_ZONE

# export image value
TF_VAR_CONSUL_IMG=gcp-centos7-consul
export TF_VAR_CONSUL_IMG

# export image value
TF_VAR_VAULT_IMG=gcp-centos7-vault
export TF_VAR_VAULT_IMG

# https://cloud.google.com/docs/authentication/production#obtaining_and_providing_service_account_credentials_manually
GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/auth/account.json
export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/auth/account.json

# activate service account with JSON creds file
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

# show authorized account (to check the correct account has been choosed)
gcloud auth list

while getopts "de" opt
do
case $opt in
d) gsutil mb -p ${TF_VAR_GP} -s coldline -l ${TF_VAR_REG} gs://${TF_VAR_GP} # create backend bucket for state saving
   cd    terraform
         terraform init                					        # terraform's provider initialization (GCP driver in this example)
   gsutil versioning set on gs://${TF_VAR_GP}				    # set versioning on the bucket
         terraform plan							                # ad-hoc check for resources creation (plan)
   cd ../packer
         packer validate consul.json					        # packer template syntax validation
         packer inspect consul.json
         packer build consul.json                  			    # image building
         # repeat with the vault image
         packer validate vault.json
         packer inspect vault.json
         packer build vault.json
   cd ../terraform 
         terraform apply -auto-approve;;					    # apply changes to GCP infra with terraform
e) cd ./terraform && terraform destroy -auto-approve;;
*) echo "No reasonable options found!";;
esac
done
