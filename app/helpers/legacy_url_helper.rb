module LegacyUrlHelper
  def atom_feed_path
    "/government/feed"
  end

  def atom_feed_url(_)
    "#{Plek.new.website_root}/government/feed"
  end
end
