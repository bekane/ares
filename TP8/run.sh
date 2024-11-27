#!/bin/bash

ansible -i hosts all -m gather_facts --tree facts

ansible-playbook -i hosts infra.yml


exit 0
