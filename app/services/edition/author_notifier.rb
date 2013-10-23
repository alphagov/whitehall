class Edition::AuthorNotifier
  attr_accessor :edition, :excluded_authors

  def self.edition_published(edition, options={})
    new(edition, [options[:user]].compact).notify!
  end

  def initialize(edition, excluded_authors)
    @edition = edition
    @excluded_authors = excluded_authors
  end

  def notify!
    authors_to_notify.each do |author|
      Notifications.edition_published(author, edition, edition_admin_url, public_document_url).deliver
    end
  end

  def authors_to_notify
    edition.authors.uniq - excluded_authors
  end

  def  edition_admin_url
    Whitehall.url_maker.admin_edition_url(edition)
  end

  def public_document_url
    Whitehall.url_maker.public_document_url(edition)
  end
end
