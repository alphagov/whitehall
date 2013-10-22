class Edition::AuthorNotifier

  def self.edition_published(edition, options={})
    excluded_authors = [options[:user]].compact
    edition_admin_url = Whitehall.url_maker.admin_edition_url(edition)
    public_document_url = Whitehall.url_maker.public_document_url(edition)

    (edition.authors.uniq - excluded_authors).each do |author|
      Notifications.edition_published(author, edition, edition_admin_url, public_document_url).deliver
    end
  end
end
