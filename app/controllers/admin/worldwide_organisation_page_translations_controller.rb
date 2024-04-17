class Admin::WorldwideOrganisationPageTranslationsController < Admin::BaseController
  include TranslationControllerConcern

  def index; end

  def edit; end

private

  def create_redirect_path
    edit_admin_editionable_worldwide_organisation_page_translation_path(@worldwide_organisation, @worldwide_page, id: translation_locale)
  end

  def destroy_redirect_path
    admin_editionable_worldwide_organisation_pages_path(@worldwide_organisation)
  end

  def update_redirect_path
    admin_editionable_worldwide_organisation_pages_path(@worldwide_organisation)
  end

  def load_translatable_item
    @worldwide_organisation = Edition.find(params[:editionable_worldwide_organisation_id])
    @worldwide_page = @worldwide_organisation.pages.find(params[:page_id])
  end

  def load_translated_models
    @translated_page = LocalisedModel.new(@worldwide_page, translation_locale.code)
    @english_page = LocalisedModel.new(@worldwide_page, :en)
  end

  def translatable_item
    @translated_page
  end

  def translated_item_name
    @translated_page.title
  end

  def translation_params
    params.require(:page)
          .permit(:title,
                  :summary,
                  :body)
  end
end
