class Admin::TopicalEventsController < Admin::ClassificationsController
  before_filter :build_associated_objects, only: [:new, :edit]
  before_filter :destroy_blank_social_media_accounts, only: [:create, :update]

  def update
    @classification = model_class.find(params[:id])
    if @classification.update_attributes(object_params)
      if object_params[:classification_featurings_attributes]
        redirect_to [:admin, @classification, :classification_featurings], notice: "Order of featured items updated"
      else
        redirect_to [:admin, model_class.new], notice: "#{human_friendly_model_name} updated"
      end
    else
      render action: "edit"
    end
  end

  private

  def model_class
    TopicalEvent
  end

  def build_associated_objects
    @classification.social_media_accounts.build
  end

  def destroy_blank_social_media_accounts
    if params[:topical_event][:social_media_accounts_attributes]
      params[:topical_event][:social_media_accounts_attributes].each do |index, account|
        if account[:social_media_service_id].blank? && account[:url].blank?
          account[:_destroy] = "1"
        end
      end
    end
  end
end
