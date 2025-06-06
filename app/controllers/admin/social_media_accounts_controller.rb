class Admin::SocialMediaAccountsController < Admin::BaseController
  before_action :find_socialable
  before_action :find_social_media_account, only: %i[edit update confirm_destroy destroy]
  before_action :enforce_permissions!
  before_action :strip_whitespace_from_url

  def index
    @social_media_accounts = @socialable.social_media_accounts
    render :index
  end

  def new
    @social_media_account = @socialable.social_media_accounts.build
    render :new
  end

  def edit
    I18n.with_locale(params[:locale] || I18n.default_locale) do
      render :edit
    end
  end

  def update
    if @social_media_account.update(social_media_account_params)
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
      render :new
    end
  end

  def confirm_destroy; end

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
      if params.key?(:organisation_id)
        Organisation.friendly.find(params[:organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def find_social_media_account
    @social_media_account = @socialable.social_media_accounts.find(params[:id])
  end

  def enforce_permissions!
    case action_name
    when "new", "create"
      enforce_permission!(:create, SocialMediaAccount)
    when "edit", "update"
      enforce_permission!(:update, @social_media_account)
    when "confirm_destroy", "destroy"
      enforce_permission!(:delete, @social_media_account)
    end
  end

  def strip_whitespace_from_url
    if params[:social_media_account] && params[:social_media_account][:url]
      params[:social_media_account][:url].strip!
    end
  end

  def social_media_account_params
    params.require(:social_media_account).permit(
      :social_media_service_id, :url, :title, :locale
    )
  end
end
