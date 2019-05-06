#! /bin/bash

virtualenv ansible -p python3
# create virtualenv called ansible with python3.
# assumming there is the python3 on your station. You can use different one.

. ansible/bin/activate
#activate the virtualenv.

pip install -r requirements.txt
# install needed packages inside the virtualenv.
