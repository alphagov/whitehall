##
## RummagerDocumentPresenter serves as a wrapper for documents returned in results
## provided by Rummager/Search API, in order to present documents in Finders.
##

class RummagerDocumentPresenter
  attr_reader :title, :link, :display_type, :summary, :content_id

  def initialize(document_hash)
    @document = document_hash
    @link = @document.fetch('link', '')
    @title = @document.fetch('title', '')
    @display_type = @document.fetch('display_type', '')
    @summary = @document.fetch('description', '')
    @content_id = @document.fetch('content_id', '')
  end

  def publication_date
    I18n.l @document.fetch('public_timestamp', '').to_date, format: :long_ordinal
  end

  def public_timestamp
    @document.fetch('public_timestamp', '').to_time
  end

  def display_type_key
    @document.fetch('display_type', '')
  end

  def id
    # This matches the Atom FeedEntryPresenter in Collections:
    # https://github.com/alphagov/collections/blob/master/app/presenters/feed_entry_presenter.rb#L9
    "#{url}##{@document['public_timestamp'].to_date.rfc3339}"
  end

  def url
    Plek.current.website_root + link
  end
end
