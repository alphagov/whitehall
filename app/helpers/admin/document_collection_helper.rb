module Admin::DocumentCollectionHelper
  def document_collection_select_options(edition, user)
    organisation = user.organisation
    grouped_collections = DocumentCollection.all.group_by(&:organisation)
    primary_collections = grouped_collections.delete(user.organisation)

    collection_options = []
    if primary_collections
      collection_options << (%{<optgroup label="#{user.organisation.name}">} +
      options_from_collection_for_select(primary_collections, 'id', 'name', edition.document_collection_ids) +
      %{</optgroup>})
    end
    collection_options << grouped_collections.map do |organisation, collections|
      %{<optgroup label="#{organisation.name}">} +
      options_from_collection_for_select(collections, 'id', 'name', edition.document_collection_ids) +
      %{</optgroup>}
    end
    collection_options.join.html_safe
  end
end
