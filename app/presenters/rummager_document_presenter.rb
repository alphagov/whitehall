##
## RummagerDocumentPresenter serves as a wrapper for documents returned in results
## provided by Rummager/Search API, in order to present documents in Finders.
##

class RummagerDocumentPresenter
  include ActionView::Helpers::UrlHelper

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

  def publication_collections
    links = @document.fetch('document_collections', []).map { |collection| collection_link(collection["title"], collection["link"]) }.compact

    "Part of a collection: #{links.to_sentence}" if links.any?
  end

  def type
    @document.fetch('format', '')
  end

  def government_name
    @document.fetch('government_name', '')
  end

  def historic?
    @document.fetch('is_historic', false)
  end

  def organisations
    orgs = @document.fetch('organisations', []).map do |organisation|
      organisation.fetch('acronym', nil) || organisation.fetch('title', nil)
    end
    orgs.compact
    orgs.to_sentence if orgs.any?
  end

private

  def collection_link(title, link)
    link_to(title, Plek.current.website_root + link)
  end
end
