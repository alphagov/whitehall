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
# Serve static shared assets from integration so static doesn't need to be running
: ${STATIC_DEV:="https://assets-origin.integration.publishing.service.gov.uk"}
export STATIC_DEV
echo
bundle install
bundle exec rails s -p 3020
