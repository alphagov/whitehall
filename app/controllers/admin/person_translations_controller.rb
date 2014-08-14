class Admin::PersonTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcern

  before_filter :load_translated_and_english_people, except: [:index]
  helper_method :translation_locale

  private

  def create_redirect_path
    edit_admin_person_translation_path(@person, id: translation_locale)
  end

  def update_attributes
    @translated_person.update_attributes(person_params)
  end

  def remove_translations
    @translated_person.remove_translations_for(translation_locale.code)
  end

  def destroy_redirect_path
    admin_person_translations_path(@translated_person)
  end

  def update_redirect_path
    admin_person_translations_path(@translated_person)
  end

  def translated_item
    @person.name
  end

  def load_translated_and_english_people
    @translated_person = LocalisedModel.new(@person, translation_locale.code)
    @english_person = LocalisedModel.new(@person, :en)
  end

  def load_translatable_items
    @person ||= Person.find(params[:person_id])
  end

  def person_params
    params.require(:person).permit(:biography)
  end
end
