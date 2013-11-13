module Admin::DocumentCollectionHelper
  def document_collection_select_options(edition, user, selected_ids)
    options = Rails.cache.fetch("document_collection_select_options", expires_in: 30.minutes) do
      DocumentCollection.alphabetical.includes(:groups).flat_map  do |collection|
        collection.groups.map do |group|
          ["#{collection.title} (#{group.heading})", group.id]
        end
      end
    end
    options_for_select(options, selected_ids)
  end
end
