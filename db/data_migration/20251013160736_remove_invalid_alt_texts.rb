# This migration builds on the validation rule added in whitehall#10729
# to remove invalid alt_texts from features associated with offsite links.
# Invalid alt_texts are those that are either longer than 255 characters or consist solely of
# spaces and/or quotes. The alt_texts of these features are set to an empty string
# to ensure they comply with the validation rules defined in the Feature model.
#
# We checked the production database to ensure that no existing Features have
# alt text longer than 255 characters, so we can safely assume that any invalid
# features' alt text must be made up entirely of spaces and/or quotes, and can
# therefore be set to an empty string.

features = OffsiteLink.all.map(&:features).flatten
invalid_features = features.reject(&:valid?)
invalid_features.each { |feature| feature.update!(alt_text: "") }
