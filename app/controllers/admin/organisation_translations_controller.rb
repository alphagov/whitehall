class Admin::OrganisationTranslationsController < Admin::BaseController
  before_filter :load_organisation
  before_filter :load_translated_and_english_organisations, except: [:index]
  helper_method :translation_locale

  def index
  end

  def create
    redirect_to edit_admin_organisation_translation_path(@organisation, id: translation_locale)
  end

  def edit
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

  def organisation_params
    params.require(:organisation).permit(
      :name, :acronym, :logo_formatted_name, :description, :about_us
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
