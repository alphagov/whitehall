class PublicationFilterJsonPresenter < DocumentFilterPresenter
  include EmailSignupHelper

  def as_json(options = nil)
    super.merge(
      atom_feed_url: context.filter_atom_feed_url,
      email_signup_url: email_signup_url,
    )
  end

  def result_type
    "publication"
  end

  def email_signup_url
    generalise_consultations(
      context.new_email_signups_path(
        email_signup: { feed: context.filter_atom_feed_url },
      ),
    )
  end
end
