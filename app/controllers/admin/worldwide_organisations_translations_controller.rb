class Admin::WorldwideOrganisationsTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcerns

  before_filter :load_translated_and_english_worldwide_organisations, except: [:index]
  helper_method :translation_locale

  private

  def create_redirect_path
    edit_admin_worldwide_organisation_translation_path(@worldwide_organisation, id: translation_locale)
  end

  def update_attributes
    @translated_worldwide_organisation.update_attributes(worldwide_organisation_params)
  end

  def remove_translations
    @translated_worldwide_organisation.remove_translations_for(translation_locale.code)
  end

  def destroy_redirect_path
    admin_worldwide_organisation_translations_path(@translated_worldwide_organisation)
  end

  def update_redirect_path
    admin_worldwide_organisation_translations_path(@translated_worldwide_organisation)
  end

  def translated_item
    @worldwide_organisation.name
  end

  def load_translated_and_english_worldwide_organisations
    @translated_worldwide_organisation = LocalisedModel.new(@worldwide_organisation, translation_locale.code)
    @english_worldwide_organisation = LocalisedModel.new(@worldwide_organisation, :en)
  end

  def load_items
    @worldwide_organisation ||= WorldwideOrganisation.find(params[:worldwide_organisation_id])
  end

  def worldwide_organisation_params
    params.require(:worldwide_organisation).permit(
      :name, :summary, :description, :services
    )
  end
end
