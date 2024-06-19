module Edition::Searchable
  extend ActiveSupport::Concern

  def search_title
    title
  end

  def search_link
    base_path
  end

  def search_format_types
    [Edition.search_format_type]
  end

  def refresh_index_if_required
    if document.editions.published.any?
      document.editions.published.last.update_in_search_index
    else
      remove_from_search_index
    end
  end

  included do
    include Searchable

    searchable(
      id: :id,
      title: :search_title,
      link: :search_link,
      format: ->(d) { d.format_name.tr(" ", "_") },
      content: :indexable_content,
      description: :summary,
      people: nil,
      roles: nil,
      display_type: :display_type,
      detailed_format: :detailed_format,
      public_timestamp: :public_timestamp,
      relevant_to_local_government: :relevant_to_local_government?,
      world_locations: nil,
      only: :search_only,
      index_after: [],
      unindex_after: [],
      search_format_types: :search_format_types,
      attachments: nil,
      operational_field: nil,
      latest_change_note: :most_recent_change_note,
      is_political: :political?,
      is_historic: :historic?,
      is_withdrawn: :withdrawn?,
      government_name: :search_government_name,
      content_store_document_type: :content_store_document_type,
    )
  end
end
