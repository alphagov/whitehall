class Admin::EditionableSocialMediaAccountsController < Admin::BaseController
  before_action :find_edition
  before_action :find_social_media_account, only: %i[edit update]

  def create
    social_media_account = SocialMediaAccount.create(social_media_account_params)

    if social_media_account.persisted?
      redirect_to admin_edition_social_media_accounts_path(@edition), notice: "Social media account '#{social_media_account.title}' created"
    else
      render :new
    end
  end

  def edit; end

  def index; end

  def new; end

  def update
    @social_media_account.attributes = social_media_account_params

    if @social_media_account.save
      redirect_to admin_edition_social_media_accounts_path(@edition), notice: "Social media account '#{@social_media_account.title}' updated"
    else
      render :edit
    end
  end

private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def find_social_media_account
    @social_media_account = SocialMediaAccount.find(params[:id])
  end

  def social_media_account_params
    params.fetch(:social_media_account, {}).permit(
      :social_media_service_id,
      :title,
      :url,
    ).merge(
      socialable: @edition,
    )
  end
end
