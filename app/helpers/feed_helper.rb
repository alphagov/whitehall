module FeedHelper
  def link_to_feed(feed_url)
    link_to "feed", feed_url, class: "feed"
  end

  def documents_as_feed_entries(documents, builder, govdelivery_version = false, feed_updated_timestamp = Time.current)
    feed_updated_timestamp =
      if documents.any?
        documents.first.public_timestamp
      else
        feed_updated_timestamp
      end
    builder.updated feed_updated_timestamp

    documents.each do |document|
      builder.entry(document, id: document_id(document, builder), url: public_document_url(document), published: document.first_public_at, updated: document.public_timestamp) do |entry|
        document_as_feed_entry(document, builder, govdelivery_version)
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
    id = record.document ? record.document.id : record.id
    "tag:#{host},#{schema_date(builder)}:#{record.class}/#{id}"
  end

  def schema_date(builder)
    builder.instance_variable_get(:@feed_options)[:schema_date]
  end

  def host
    request.host
  end

  def document_as_feed_entry(document, builder, govdelivery_version = false)
    builder.title "#{document.display_type}: #{document.title}"
    builder.category label: document.display_type, term: document.display_type
    builder.summary document.summary
    builder.content entry_content(document, govdelivery_version), type: 'html'
  end

  def entry_content(document, govdelivery_version = false)
    # First published versions don't have change notes
    unless document.first_published_version?
      # Change notes are only on major published versions
      if document.minor_change?
        previous_major_version = Edition.unscoped.where( 'document_id=? and published_major_version=? and published_minor_version=0', document.document_id, document.published_major_version )
        change_note = previous_major_version.first.change_note
      else
        change_note = document.change_note
      end

      if change_note
        change_note = "<p><em>Change note:</em> #{change_note}</p>"
      end
    end

    if govdelivery_version
      "<p>#{document.summary}</p>#{change_note}"
    else
      "#{govspeak_edition_to_html(document)}#{change_note}"
    end
  end

  def feed_wants_govdelivery_version?
    if params[:govdelivery_version].present? && params[:govdelivery_version] =~ /\A(?:true|yes|1|on)\Z/i
      true
    else
      false
    end
  end
end
