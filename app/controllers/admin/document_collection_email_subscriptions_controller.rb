class Admin::DocumentCollectionEmailSubscriptionsController < Admin::BaseController
  include Admin::DocumentCollectionEmailOverrideHelper
  before_action :load_document_collection

  def edit; end

private

  def load_document_collection
    @collection = DocumentCollection.find(params[:document_collection_id])
  end
end
