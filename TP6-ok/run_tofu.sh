#!/bin/bash



yes yes | tofu destroy
tofu init
yes yes | tofu plan
yes yes | tofu apply



exit 0

