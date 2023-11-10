class Admin::DocumentCollectionEmailSubscriptionsController < Admin::BaseController
  before_action :load_document_collection
  before_action :authorise_user
  layout "design_system"

  def edit; end

  def update
    if user_has_selected_taxonomy_topic_emails?
      if all_required_params_present?
        @collection.update!(taxonomy_topic_email_override: params["selected_taxon_content_id"])
      else
        build_missing_params_flash
        return redirect_to form_with_stored_params
      end
    else
      @collection.update!(taxonomy_topic_email_override: nil)
    end
    build_flash("notice")
    redirect_to edit_admin_document_collection_path(@collection)
  rescue ActiveRecord::RecordInvalid
    redirect_to admin_document_collection_path(@collection)
  end

private

  def all_required_params_present?
    required_params.select { |key| params[key].present? } == required_params
  end

  def required_params
    %w[selected_taxon_content_id email_override_confirmation]
  end

  def form_with_stored_params
    admin_document_collection_edit_email_subscription_path(@collection, params_to_store_state_of_failed_form_submission)
  end

  def build_missing_params_flash
    mmissing_params = required_params.select { |required_param| params[required_param].blank? }
    missing_params.each { |key| build_flash(key) }
  end

  def build_flash(key)
    flash[key] = {
      "selected_taxon_content_id" => "You must choose a topic",
      "email_override_confirmation" => "You must confirm you’re happy with the email notification settings",
      "notice" => "You’ve selected the email notification settings. You cannot change these settings after the collection is published",
    }[key]
  end

  def params_to_store_state_of_failed_form_submission
    {
      "selected_taxon_content_id" => params["selected_taxon_content_id"],
      "override_email_subscriptions" => params["override_email_subscriptions"],
    }
  end

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
