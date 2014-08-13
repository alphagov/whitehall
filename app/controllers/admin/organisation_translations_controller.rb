class Admin::OrganisationTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcerns

  before_filter :load_organisation
  before_filter :load_translated_and_english_organisations, except: [:index]
  helper_method :translation_locale

  def index
  end

  def update
    if @translated_organisation.update_attributes(organisation_params)
      redirect_to admin_organisation_translations_path(@translated_organisation),
        notice: notice_message("saved")
    else
      render action: 'edit'
    end
  end

  def destroy
    @translated_organisation.remove_translations_for(translation_locale.code)
    redirect_to admin_organisation_translations_path(@translated_organisation),
      notice: notice_message("deleted")
  end

  private

  def create_redirect_path
    edit_admin_organisation_translation_path(@organisation, id: translation_locale)
  end

  def organisation_params
    params.require(:organisation).permit(
      :name, :acronym, :logo_formatted_name
    )
  end

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@organisation.name}" #{action}.}
  end

  def load_translated_and_english_organisations
    @translated_organisation = LocalisedModel.new(@organisation, translation_locale.code)
    @english_organisation = LocalisedModel.new(@organisation, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def load_organisation
    @organisation ||= Organisation.find(params[:organisation_id])
  end
end
