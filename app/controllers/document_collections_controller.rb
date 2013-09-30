class DocumentCollectionsController < DocumentsController
  def show
    expire_on_next_scheduled_publication(@document.editions)
    @document_collection = DocumentCollectionPresenter.new(@document, view_context)
    @meta_description = @document_collection.summary
  end

private
  def document_class
    DocumentCollection
  end
end
