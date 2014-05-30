class Whitehall::Controllers::SocialMedia
  def build_social_media_account(object)
    unless object.social_media_accounts.any?(&:new_record?)
      object.social_media_accounts.build
    end
  end

  def destroy_blank_social_media_accounts(object_params)
    if object_params[:social_media_accounts_attributes]
      object_params[:social_media_accounts_attributes].each do |_index, account|
        if account[:social_media_service_id].blank? && account[:url].blank?
          account[:_destroy] = "1"
        end
      end
    end
  end
end
