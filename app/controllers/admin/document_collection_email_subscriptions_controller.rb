class Admin::DocumentCollectionEmailSubscriptionsController < Admin::BaseController
  include Admin::DocumentCollectionEmailOverrideHelper
  before_action :load_document_collection
  before_action :authorise_user

  def edit
    @topic_list_select_presenter = TopicListSelectPresenter.new(@collection.taxonomy_topic_email_override)
  end

private

  def load_document_collection
    @collection = DocumentCollection.find(params[:document_collection_id])
  end

  def authorise_user
    redirect_to edit_admin_document_collection_path(@collection) unless current_user.can_edit_email_overrides?
  end
end
