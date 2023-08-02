class Admin::DocumentCollectionEmailSubscriptionsController < Admin::BaseController
  layout "design_system"
  def edit
    @collection = DocumentCollection.find(params[:document_collection_id])

    redirect_to admin_document_collection_path(@collection) unless current_user.can_edit_email_overrides?
  end
end
