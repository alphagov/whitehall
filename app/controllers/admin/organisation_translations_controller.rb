class Admin::OrganisationTranslationsController < Admin::BaseController
  include TranslationControllerConcern
  layout :get_layout

  def index
    render :legacy_index
  end

private

  def get_layout
    design_system_actions = %w[confirm_destroy]

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

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
      :name, :acronym, :logo_formatted_name,
      featured_links_attributes: %i[title url _destroy id]
    )
  end

  def translatable_item
    @translated_organisation
  end

  def translated_item_name
    @organisation.name
  end

  def load_translated_models
    @translated_organisation = LocalisedModel.new(@organisation, translation_locale.code, [:featured_links])
    @english_organisation = LocalisedModel.new(@organisation, :en)
  end

  def load_translatable_item
    @organisation = Organisation.friendly.find(params[:organisation_id])
  end
end
