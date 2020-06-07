#!/bin/bash

values=$(terraform output -json)

let i=0
for username in $(echo $values | jq -r '.students.value[].name'); do
  echo "Instructions repo:     https://github.com/rockholla/terraform-packer-workshop"
  echo "Console URL:           https://rockholla-di.signin.aws.amazon.com/console"
  echo "Username/Alias:        $username"
  password=$(echo $values | jq -r '.passwords.value[]['"$i"']' | base64 --decode | gpg -dq)
  echo "AWS Console Password:  $password"
  region=$(echo $values | jq -r '.students.value['"$i"'].region')
  echo "Exercise 11 Region:    $region"
  echo "Instructor email:      patrick+di@rockholla.org"
  echo ""
  echo ""
  echo ""
  let i=i+1
done
