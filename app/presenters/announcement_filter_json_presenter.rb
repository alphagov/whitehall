class AnnouncementFilterJsonPresenter < DocumentFilterPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: context.filter_atom_feed_url,
                email_signup_url: context.new_email_signups_path(feed: ERB::Util.url_encode(context.filter_atom_feed_url))
  end

  def result_type
    "announcement"
  end
end
