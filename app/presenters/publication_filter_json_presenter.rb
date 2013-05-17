class PublicationFilterJsonPresenter < DocumentFilterPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: context.filter_atom_feed_url,
                email_signup_url: context.filter_email_signup_url(document_type: 'publication_type_all')
  end
end
