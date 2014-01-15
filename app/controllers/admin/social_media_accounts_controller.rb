class Admin::SocialMediaAccountsController < Admin::BaseController
  before_filter :find_socialable
  before_filter :find_social_media_account, only: [:edit, :update, :destroy]
  before_filter :strip_whitespace_from_url

  def index
    @social_media_accounts = @socialable.social_media_accounts
  end

  def new
    @social_media_account = @socialable.social_media_accounts.build
  end

  def edit
  end

  def update
    @social_media_account.update_attributes(social_media_account_params)
    if @social_media_account.save
      redirect_to [:admin, @socialable, SocialMediaAccount],
        notice: "#{@social_media_account.service_name} account updated successfully"
    else
      render :edit
    end
  end

  def create
    @social_media_account = @socialable.social_media_accounts.build(social_media_account_params)
    if @social_media_account.save
      redirect_to [:admin, @socialable, SocialMediaAccount],
        notice: "#{@social_media_account.service_name} account created successfully"
    else
      render :edit
    end
  end

  def destroy
    if @social_media_account.destroy
      redirect_to [:admin, @socialable, SocialMediaAccount],
        notice: "#{@social_media_account.service_name} account deleted successfully"
    else
      render :edit
    end
  end

private

  def find_socialable
    @socialable =
      if params.has_key?(:organisation_id)
        Organisation.find(params[:organisation_id])
      elsif params.has_key?(:worldwide_organisation_id)
        WorldwideOrganisation.find(params[:worldwide_organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def find_social_media_account
    @social_media_account = @socialable.social_media_accounts.find(params[:id])
  end

  def strip_whitespace_from_url
    if params[:social_media_account] && params[:social_media_account][:url]
      params[:social_media_account][:url].strip!
    end
  end

  def social_media_account_params
    params.require(:social_media_account).permit(
      :social_media_service_id, :url, :title
    )
  end
end
