class DocumentCollectionsController < DocumentsController
  def show
    expire_on_next_scheduled_publication(@document.editions)
    @document_collection = @document
    @groups = @document_collection.groups.visible.map do |group|
      editions = EditionCollectionPresenter.new(group.published_editions, view_context)
      [group, editions]
    end
  end

private
  def document_class
    DocumentCollection
  end
end
