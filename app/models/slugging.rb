module Slugging
  # TODO: This is now the behaviour of friendly_id so this can probably be removed
  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(input)
    input.to_s.to_slug.truncate(150).normalize.to_s
  end
end
