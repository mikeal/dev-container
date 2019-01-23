#!/bin/sh

eval $(op signin https://my.1password.com mikeal.rogers@gmail.com)

SCRIPT=$(op get item ConfigureDev)
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo SCRIPT | jq -r '.details.notesPlain' | sh
  echo "Added Secrets :)"
  tmux
else
  echo "Login failed :("
  exit
fi
