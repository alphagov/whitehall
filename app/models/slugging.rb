module Slugging
  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(input)
    super input.to_s.to_slug.truncate(150).normalize.to_s
  end
end
