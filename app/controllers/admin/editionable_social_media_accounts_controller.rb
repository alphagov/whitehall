class Admin::EditionableSocialMediaAccountsController < Admin::BaseController
  before_action :find_edition
  before_action :find_social_media_account, only: %i[confirm_destroy destroy edit update]

  def confirm_destroy; end

  def create
    social_media_account = SocialMediaAccount.create(social_media_account_params)

    if social_media_account.persisted?
      redirect_to admin_edition_social_media_accounts_path(@edition), notice: "Social media account '#{social_media_account.title}' created"
    else
      render :new
    end
  end

  def destroy
    if @social_media_account.destroy
      redirect_to admin_edition_social_media_accounts_path(@edition), notice: "#{@social_media_account.service_name} account deleted successfully"
    else
      render :edit
    end
  end

  def edit
    I18n.with_locale(params[:locale] || I18n.default_locale) do
      render :edit
    end
  end

  def index
    @editionable_social_media_accounts_index_presenter = EditionableSocialMediaAccountsIndexPresenter.new(@edition)
  end

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
      :locale,
      :social_media_service_id,
      :title,
      :url,
    ).merge(
      socialable: @edition,
    )
  end
end
