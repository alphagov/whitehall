module EmailSignupHelper
  def email_signup_path(atom_feed_url)
    feed_uri = URI.parse(atom_feed_url)

    if mhra_exists_for_atom_feed?(atom_feed_url)
      mhra_email_signup_path_from_atom_feed(atom_feed_url)
    elsif feed_uri.path.match(%r{^/world/(.*)\.atom$})
      topic = feed_uri.path.scan(%r{^/world/(.*?)(\..*)?\.atom$}).flatten.first
      email_alert_frontend_signup_for_topic_url(topic)
    else
      email_alert_frontend_signup_for_link_url(feed_uri)
    end
  rescue URI::InvalidURIError
    "/"
  end

private

  def mhra_email_signup_path_from_atom_feed(atom_feed_url)
    mhra_email_signup_path extract_slug_from_atom_feed(atom_feed_url)
  end

  def extract_slug_from_atom_feed(atom_feed_url)
    /\/([\w-]+).atom$/.match(atom_feed_url)[1]
  end

  def email_alert_frontend_signup_for_link_url(feed_uri)
    "#{Plek.new.website_root}/email-signup?link=#{feed_uri.path.chomp('.atom')}"
  end

  def email_alert_frontend_signup_for_topic_url(topic)
    "#{Plek.new.website_root}/email-signup?topic=#{topic}"
  end

  def mhra_exists_for_atom_feed?(atom_feed_url)
    atom_feed_url.ends_with?("medicines-and-healthcare-products-regulatory-agency.atom")
  end
end
