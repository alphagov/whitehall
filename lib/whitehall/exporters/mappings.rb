class Whitehall::Exporters::Mappings
  STATES_TO_INCLUDE = Edition::PRE_PUBLICATION_STATES + %w(published withdrawn)

  def export(target)
    target << ['Old URL', 'New URL', 'Admin URL', 'State']
    Document.find_each do |document|
      edition = document.published_edition || document.latest_edition
      if edition && STATES_TO_INCLUDE.include?(edition.state)
        document.document_sources.each do |document_source|
          begin
            next if fake_source_url?(document_source)
            target << document_row(edition, document, document_source)
          rescue StandardError => e
            Rails.logger.error("#{self.class.name}: when exporting #{edition} - #{e} - #{e.backtrace.join("\n")}")
          end
        end
      end
    end

    AttachmentSource.find_each do |attachment_source|
      begin
        next if fake_source_url?(attachment_source)
        if attachment_source.attachment
          path = attachment_source.attachment.url
          attachment_url = "#{Whitehall.public_root}#{path}"
          attachment_data = attachment_source.attachment.attachment_data
          state = attachment_data.visible_to?(nil) ? 'published' : 'draft'
          target << [attachment_source.url, attachment_url, '', state]
        end
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
      url_maker.admin_edition_url(edition, host: Whitehall.admin_host),
      edition.state
    ]
  end

  def document_url(edition, document, document_source)
    doc_url_args = { id: document.slug }
    if document_source.locale && !Locale.new(document_source.locale).english?
      doc_url_args[:locale] = document_source.locale
    end
    edition_type_for_route = edition.class.name.underscore
    url_maker.polymorphic_url(edition_type_for_route, doc_url_args)
  end

  def fake_source_url?(source)
    source.url =~ /(fabricatedurl|placeholderunique|github)/i
  end

  def url_maker
    @url_maker ||= Whitehall.url_maker
  end
end
