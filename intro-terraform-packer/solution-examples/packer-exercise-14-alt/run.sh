#!/bin/bash

region="us-west-2"
source_ami_id="ami-02d0ea44ae3fe9561"
ami_name="force-exercise-14"

cd packer/
packer build \
  -var region="${region}" \
  -var source_ami_id="${source_ami_id}" \
  -var ami_name="${ami_name}"\
  template.json
cd ../terraform
terraform init
terraform apply \
  -auto-approve \
  -var region="${region}" \
  -var ami_name="${ami_name}"