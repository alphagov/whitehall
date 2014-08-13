class Admin::PersonTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcerns

  before_filter :load_person
  before_filter :load_translated_and_english_people, except: [:index]
  helper_method :translation_locale

  def index
  end

  def destroy
    @translated_person.remove_translations_for(translation_locale.code)
    redirect_to admin_person_translations_path(@translated_person),
      notice: notice_message("deleted")
  end

  private

  def create_redirect_path
    edit_admin_person_translation_path(@person, id: translation_locale)
  end

  def update_attributes
    @translated_person.update_attributes(person_params)
  end

  def update_redirect_path
    admin_person_translations_path(@translated_person)
  end

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@person.name}" #{action}.}
  end

  def load_translated_and_english_people
    @translated_person = LocalisedModel.new(@person, translation_locale.code)
    @english_person = LocalisedModel.new(@person, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def load_person
    @person ||= Person.find(params[:person_id])
  end

  def person_params
    params.require(:person).permit(:biography)
  end
end
