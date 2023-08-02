class Admin::DocumentCollectionEmailSubscriptionsController < Admin::BaseController
  before_action :load_document_collection
  before_action :authorise_user
  layout "design_system"

  def edit; end

  def update
    if user_has_selected_taxonomy_topic_emails?
      if params[:selected_taxon_content_id].blank?
        flash[:placeholder] = "message 1"
        return redirect_to admin_document_collection_edit_email_subscription_path(@collection)
      elsif params[:email_override_confirmation].blank?
        flash[:placeholder] = "message 2"
        return redirect_to admin_document_collection_edit_email_subscription_path(@collection)
      else
        @collection.update!(taxonomy_topic_email_override: params[:selected_taxon_content_id])
      end
    else
      @collection.update!(taxonomy_topic_email_override: nil)
    end
    flash[:placeholder] = "message 3"
    redirect_to edit_admin_document_collection_path(@collection)
  end

private

  def load_document_collection
    @collection = DocumentCollection.find(params[:document_collection_id])
  end

  def authorise_user
    redirect_to edit_admin_document_collection_path(@collection) unless current_user.can_edit_email_overrides?
  end

  def user_has_selected_taxonomy_topic_emails?
    params[:override_email_subscriptions] == "true"
  end
end
