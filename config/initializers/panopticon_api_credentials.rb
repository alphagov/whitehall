# This file is overridden on deploy

PANOPTICON_API_CREDENTIALS = {
  bearer_token: ENV.fetch("PANOPTICON_BEARER_TOKEN", "developmentapicredentials"),
}
