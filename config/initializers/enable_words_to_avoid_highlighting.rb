# this feature flag gets overridden on deploy
ENABLE_WORDS_TO_AVOID_HIGHLIGHTING = ! Rails.env.production?
