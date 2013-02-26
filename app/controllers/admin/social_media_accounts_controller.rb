class Admin::SocialMediaAccountsController < Admin::BaseController
  before_filter :find_socialable
  before_filter :find_social_media_account, only: [:edit, :update, :destroy]

  def index
    @social_media_accounts = @socialable.social_media_accounts
  end

  def new
    @social_media_account = @socialable.social_media_accounts.build
  end

  def edit
  end

  def update
    @social_media_account.update_attributes(params[:social_media_account])
    if @social_media_account.save
      redirect_to [:admin, @socialable, SocialMediaAccount], notice: "#{@social_media_account.service_name} account updated successfully"
    else
      render :edit
    end
  end

  def create
    @social_media_account = @socialable.social_media_accounts.build(params[:social_media_account])
    if @social_media_account.save
      redirect_to [:admin, @socialable, SocialMediaAccount], notice: "#{@social_media_account.service_name} account created successfully"
    else
      render :edit
    end
  end

  def destroy
    if @social_media_account.destroy
      redirect_to [:admin, @socialable, SocialMediaAccount], notice: "#{@social_media_account.service_name} account deleted successfully"
    else
      render :edit
    end
  end

  private

  def find_socialable
    @socialable = case params.keys.grep(/(.+)_id$/).first.to_sym
    when :organisation_id
      Organisation.find(params[:organisation_id])
    when :worldwide_organisation_id
      WorldwideOrganisation.find(params[:worldwide_organisation_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_social_media_account
    @social_media_account = @socialable.social_media_accounts.find(params[:id])
  end
end
