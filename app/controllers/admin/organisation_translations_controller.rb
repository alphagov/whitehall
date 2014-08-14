class Admin::OrganisationTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcern

  helper_method :translation_locale

  private

  def create_redirect_path
    edit_admin_organisation_translation_path(@organisation, id: translation_locale)
  end

  def destroy_redirect_path
    admin_organisation_translations_path(@translated_organisation)
  end

  def update_redirect_path
    admin_organisation_translations_path(@translated_organisation)
  end

  def translation_params
    params.require(:organisation).permit(
      :name, :acronym, :logo_formatted_name
    )
  end

  def translatable_item
    @translated_organisation
  end

  def translated_item
    @organisation.name
  end

  def load_translated_models
    @translated_organisation = LocalisedModel.new(@organisation, translation_locale.code)
    @english_organisation = LocalisedModel.new(@organisation, :en)
  end

  def load_translatable_items
    @organisation ||= Organisation.find(params[:organisation_id])
  end
end
