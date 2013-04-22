class AnnouncementFilterJsonPresenter < DocumentFilterPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.filter_atom_feed_url, email_signup_url: h.filter_email_signup_url
  end
end
