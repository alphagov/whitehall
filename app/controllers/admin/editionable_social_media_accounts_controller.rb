class Admin::EditionableSocialMediaAccountsController < Admin::BaseController
  before_action :find_edition
  before_action :find_social_media_account, except: [:index]

  def edit; end

  def index; end

  def update
    @social_media_account.attributes = params.fetch(:social_media_account, {}).permit(
      :social_media_service_id,
      :title,
      :url,
    )

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
end
