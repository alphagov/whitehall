module FeedHelper
  def atom_feed_url_for(resource)
    Whitehall.atom_feed_maker.url_for(resource)
  end

  def documents_as_feed_entries(documents, builder, feed_updated_timestamp = Time.current)
    # This is to support cases where the documents feed has been provided by
    # another service (e.g. Rummager) rather than from Whitehall via ActiveRecord.
    if documents.is_a?(GdsApi::Response) && documents['results']
      documents = documents['results']
    end

    feed_updated_timestamp =
      if documents.any?
        documents.first.public_timestamp
      else
        feed_updated_timestamp
      end
    builder.updated feed_updated_timestamp

    documents.each do |document|
      builder.entry(document, id: document_id(document, builder), url: public_document_url(document), published: document.try(:first_public_at), updated: document.public_timestamp) do |_entry|
        document_as_feed_entry(document, builder)
      end
    end
  end

  def document_id(record, builder)
    # This slightly clunky logic is to give entries a consistent ID -
    # the default `record.id` is the latest edition, which means the
    # entries would get a new ID for each version, which breaks the
    # spec.
    # The interpolation logic is straight out of:
    # http://api.rubyonrails.org/classes/ActionView/Helpers/AtomFeedHelper/AtomFeedBuilder.html#method-i-entry
    id = record.try(:document) ? record.document.id : record.id
    "tag:#{host},#{schema_date(builder)}:#{record.class}/#{id}"
  end

  def schema_date(builder)
    builder.instance_variable_get(:@feed_options)[:schema_date]
  end

  def host
    request.host
  end

  def feed_display_type_for(document)
    return "News story" if document.is_a?(WorldLocationNewsArticle)
    document.display_type
  end

  def document_as_feed_entry(document, builder)
    builder.title "#{feed_display_type_for(document)}: #{document.title}"
    builder.category label: document.display_type, term: document.display_type
    builder.summary entry_summary(document)
    builder.content entry_content(document), type: 'html'
  end

  def entry_summary(document)
    document.summary
  end

  def entry_content(document)
    return '' if document.is_a?(RummagerDocumentPresenter)
    change_note = document.most_recent_change_note
    change_note = "<p><em>Updated:</em> #{change_note}</p>" if change_note
    "#{change_note}#{govspeak_edition_to_html(document)}"
  end
end
