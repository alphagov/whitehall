module FeedHelper
  def atom_feed_url_for(resource)
    if resource.instance_of?(TopicalEvent)
      Whitehall.url_maker.topical_event_url(resource, format: "atom")
    else
      Whitehall.atom_feed_maker.url_for(resource)
    end
  end

  def documents_as_feed_entries(documents, builder, feed_updated_timestamp = Time.zone.now)
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
    if record.is_a?(RummagerDocumentPresenter)
      record.id
    else
      id = record&.document&.id || record.id

      "tag:#{host},#{schema_date(builder)}:#{record.class}/#{id}"
    end
  end

  def schema_date(builder)
    builder.instance_variable_get(:@feed_options)[:schema_date]
  end

  delegate :host, to: :request

  def feed_display_type_for(document)
    document.display_type
  end

  def document_as_feed_entry(document, builder)
    builder.title "#{feed_display_type_for(document)}: #{document.title}"
    builder.category label: document.display_type, term: document.display_type
    builder.summary entry_summary(document)
    builder.content(entry_content(document), type: "html") unless document.is_a?(RummagerDocumentPresenter)
  end

  def entry_summary(document)
    document.summary
  end

  def entry_content(document)
    change_note = document.most_recent_change_note
    change_note = "<p><em>Updated:</em> #{change_note}</p>" if change_note
    "#{change_note}#{govspeak_edition_to_html(document)}"
  end
end
