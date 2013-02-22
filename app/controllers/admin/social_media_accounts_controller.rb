class Admin::SocialMediaAccountsController < Admin::BaseController
  include Admin::SocialMediaAccountsHelper

  respond_to :html

  before_filter :find_socialable, only: [:new, :create]
  before_filter :find_social_media_account, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @social_media_account = @socialable.social_media_accounts.build
  end

  def edit
  end

  def update
    @social_media_account.update_attributes(params[:social_media_account])
    if @social_media_account.save
      redirect_to(social_media_accounts_list_url_for(@social_media_account.socialable))
    else
      render :edit
    end
  end

  def create
    @social_media_account = @socialable.social_media_accounts.build(params[:social_media_account])
    if @social_media_account.save
      redirect_to(social_media_accounts_list_url_for(@social_media_account.socialable))
    else
      render :edit
    end
  end

  def destroy
    if @social_media_account.destroy
      redirect_to(social_media_accounts_list_url_for(@social_media_account.socialable))
    else
      render :edit
    end
  end

private
  def find_socialable
    @socialable = case params[:socialable_type]
    when "Organisation"
      Organisation.find(params[:socialable_id])
    when "WorldwideOrganisation"
      WorldwideOrganisation.find(params[:socialable_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_social_media_account
    @social_media_account = SocialMediaAccount.find(params[:id])
    @socialable = @social_media_account.socialable
  end

end
