class DocumentCollectionsController < DocumentsController

  def show
    cache_max_age(Whitehall.document_collections_cache_max_age)
    expire_on_next_scheduled_publication(@document.editions)

    @document_collection = @document
    set_meta_description(@document_collection.summary)
    @groups = @document_collection.groups.visible.map do |group|
      editions = EditionCollectionPresenter.new(group.published_editions, view_context)
      [group, editions]
    end
  end

private

  def set_cache_control_headers
    expires_in Whitehall.document_collections_cache_max_age, public: true
  end

  def document_class
    DocumentCollection
  end
end
