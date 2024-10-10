#!/bin/bash

set -e

tofu init --upgrade
yes yes | tofu destroy

yes yes | tofu plan
yes yes | tofu apply


exit 0
