class AnnouncementFilterJsonPresenter < DocumentFilterPresenter
  include EmailSignupHelper

  def as_json(options = nil)
    super.merge(
      atom_feed_url:,
      email_signup_url:,
    )
  end

  def result_type
    "announcement"
  end

  def atom_feed_url
    context.filter_atom_feed_url
  end

  def email_signup_url
    email_signup_path(context.filter_atom_feed_url)
  end
end
