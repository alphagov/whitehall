class Admin::OrganisationTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcern

  before_filter :load_translated_and_english_organisations, except: [:index]
  helper_method :translation_locale

  private

  def create_redirect_path
    edit_admin_organisation_translation_path(@organisation, id: translation_locale)
  end

  def update_attributes
    @translated_organisation.update_attributes(organisation_params)
  end

  def remove_translations
    @translated_organisation.remove_translations_for(translation_locale.code)
  end

  def destroy_redirect_path
    admin_organisation_translations_path(@translated_organisation)
  end

  def update_redirect_path
    admin_organisation_translations_path(@translated_organisation)
  end

  def organisation_params
    params.require(:organisation).permit(
      :name, :acronym, :logo_formatted_name
    )
  end

  def translated_item
    @organisation.name
  end

  def load_translated_and_english_organisations
    @translated_organisation = LocalisedModel.new(@organisation, translation_locale.code)
    @english_organisation = LocalisedModel.new(@organisation, :en)
  end

  def load_translatable_items
    @organisation ||= Organisation.find(params[:organisation_id])
  end
end
