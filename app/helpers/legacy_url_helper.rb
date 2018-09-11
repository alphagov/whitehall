module LegacyUrlHelper
  def atom_feed_path
    "/government/feed"
  end

  def atom_feed_url(_options)
    "#{Plek.new.website_root}/government/feed"
  end
end
