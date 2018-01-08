enabled = if ENV.has_key?("HIGHLIGHT_WORDS_TO_AVOID")
            "true" == ENV["HIGHLIGHT_WORDS_TO_AVOID"]
          else
            !Rails.env.production?
          end

# Typically this isn't enabled in production
# It is primarily used as a training feature.
ENABLE_WORDS_TO_AVOID_HIGHLIGHTING = enabled
