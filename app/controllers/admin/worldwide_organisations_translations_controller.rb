class Admin::WorldwideOrganisationsTranslationsController < Admin::BaseController
  include TranslationControllerConcern

private

  def create_redirect_path
    edit_admin_worldwide_organisation_translation_path(@worldwide_organisation, id: translation_locale)
  end

  def destroy_redirect_path
    admin_worldwide_organisation_translations_path(@translated_worldwide_organisation)
  end

  def update_redirect_path
    admin_worldwide_organisation_translations_path(@translated_worldwide_organisation)
  end

  def translatable_item
    @translated_worldwide_organisation
  end

  def translated_item_name
    @worldwide_organisation.name
  end

  def load_translated_models
    @translated_worldwide_organisation = LocalisedModel.new(@worldwide_organisation, translation_locale.code)
    @english_worldwide_organisation = LocalisedModel.new(@worldwide_organisation, :en)
  end

  def load_translatable_item
    @worldwide_organisation = WorldwideOrganisation.friendly.find(params[:worldwide_organisation_id])
  end

  def translation_params
    params.require(:worldwide_organisation).permit(
      :name, :summary, :description, :services
    )
  end
end
