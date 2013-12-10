class Whitehall::Exporters::Mappings < Struct.new(:platform)
  def export(target)
    target << ['Old URL','New URL','Admin URL','State']
    Document.find_each do |document|
      edition = document.published_edition
      document.document_sources.each do |document_source|
        target << row(edition, document, document_source)
      end
    end
  end

private
  def row(edition, document, document_source)
    public_url = document_url(edition, document, document_source)
    [
      document_source.url,
      public_url,
      url_maker.admin_edition_url(edition, host: admin_host),
      edition.state
    ]
  end

  def document_url(edition, document, document_source)
    doc_url_args = {}
    slug = document_slug(edition, document)
    edition_type_for_route = edition.class.name.underscore
    url_maker.polymorphic_url(edition_type_for_route, doc_url_args.merge(id: slug))
  end

  def document_slug(edition, document)
    document.slug
  end

  def url_maker
    @url_maker ||= Whitehall::UrlMaker.new(host: public_host, protocol: 'https')
  end

  def public_host
    Whitehall.public_host_for("whitehall.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk")
  end

  def admin_host
    "whitehall-admin.#{platform}.alphagov.co.uk"
  end
end
