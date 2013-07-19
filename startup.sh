#!/bin/bash

if [ -z "$SHOW_PRODUCTION_IMAGES" ]; then
  echo "You're not showing production images. "
  echo
  echo "If you want to, then run like this instead:"
  echo
  echo "$ SHOW_PRODUCTION_IMAGES=1 ./startup.sh"
else
  echo "Showing production images"
fi
echo
bundle install
bundle exec rails s thin -p 3020
