class Whitehall::Exporters::Mappings < Struct.new(:platform)
  STATES_TO_INCLUDE = Edition::PRE_PUBLICATION_STATES + ['published'] + ['archived']

  def export(target)
    target << ['Old URL','New URL','Admin URL','State']
    Document.find_each do |document|
      edition = document.published_edition || document.latest_edition
      if edition && STATES_TO_INCLUDE.include?(edition.state)
        document.document_sources.each do |document_source|
          begin
            target << document_row(edition, document, document_source)
          rescue StandardError => e
            Rails.logger.error("#{self.class.name}: when exporting #{edition} - #{e} - #{e.backtrace.join("\n")}")
          end
        end
      end
    end

    AttachmentSource.find_each do |attachment_source|
      begin
        path = attachment_source.attachment.url
        attachment_url = 'https://' + public_host + path
        target << [attachment_source.url, attachment_url, '', 'published']
      rescue StandardError => e
        Rails.logger.error("#{self.class.name}: when exporting #{attachment_source} - #{e} - #{e.backtrace.join("\n")}")
      end
    end
  end

private
  def document_row(edition, document, document_source)
    public_url = document_url(edition, document, document_source)
    [
      document_source.url,
      public_url,
      url_maker.admin_edition_url(edition, host: admin_host),
      edition.state
    ]
  end

  def document_url(edition, document, document_source)
    doc_url_args = { id: document.slug }
    if document_source.locale && ! Locale.new(document_source.locale).english?
      doc_url_args[:locale] = document_source.locale
    end
    edition_type_for_route = edition.class.name.underscore
    url_maker.polymorphic_url(edition_type_for_route, doc_url_args)
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
