#!/bin/sh

eval $(op signin https://my.1password.com mikeal.rogers@gmail.com)

SCRIPT=$(op get document add-secrets.sh)
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo $SCRIPT | sh
  echo "Added Secrets :)"
  tmux
else
  echo "Login failed :("
  exit
fi