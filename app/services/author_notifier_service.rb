class AuthorNotifierService
  attr_accessor :edition, :excluded_authors

  def self.call(edition, *excluded_authors)
    new(edition, *excluded_authors).notify!
  end

  def initialize(edition, *excluded_authors)
    @edition = edition
    @excluded_authors = excluded_authors
  end

  def notify!
    authors_to_notify.each do |author|
      MailNotifications.edition_published(
        author,
        edition,
        edition_admin_url,
        public_document_url,
      ).deliver_now
    rescue Notifications::Client::BadRequestError => e
      # in production we care about all errors
      # in staging and integration the team-only error is unrecoverable when running asynchronously
      # (team-only error is unrecoverable in production too, but almost certainly impossible)
      raise if ENV["SENTRY_CURRENT_ENV"] !~ /integration|staging/ || e.message !~ /team-only API key/
    end
  end

  def authors_to_notify
    edition.authors.uniq - excluded_authors
  end

  def edition_admin_url
    Whitehall.url_maker.admin_edition_url(edition)
  end

  def public_document_url
    Whitehall.url_maker.public_document_url(edition)
  end
end
