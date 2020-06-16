#!/bin/bash

if [ -z "$SHOW_PRODUCTION_IMAGES" ]; then
  echo "You're not showing production images. "
  echo
  echo "If you want to, then run like this instead:"
  echo
  echo "$ SHOW_PRODUCTION_IMAGES=1 ./startup.sh"
else
  echo "Showing production images"
  export GOVUK_ASSET_HOST=https://assets.publishing.service.gov.uk
fi

# Serve static from production
export PLEK_SERVICE_STATIC_URI=https://assets.publishing.service.gov.uk
echo
bundle install
bundle exec rails s -p 3020
