class StatisticsFilterJsonPresenter < DocumentFilterPresenter
  def as_json(options = nil)
    super.merge(
      atom_feed_url: atom_feed_url,
      email_signup_url: email_signup_url,
    )
  end

  def result_type
    "statistic"
  end

  def atom_feed_url
    context.filter_atom_feed_url
  end

  def email_signup_url
    context.new_email_signups_path(email_signup: { feed: context.filter_atom_feed_url })
  end
end
