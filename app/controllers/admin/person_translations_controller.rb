class Admin::PersonTranslationsController < Admin::BaseController
  include TranslationControllerConcern

private

  def create_redirect_path
    edit_admin_person_translation_path(@person, id: translation_locale)
  end

  def destroy_redirect_path
    admin_person_translations_path(@translated_person)
  end

  def update_redirect_path
    admin_person_translations_path(@translated_person)
  end

  def translatable_item
    @translated_person
  end

  def translated_item_name
    @person.name
  end

  def load_translated_models
    @translated_person = LocalisedModel.new(@person, translation_locale.code)
    @english_person = LocalisedModel.new(@person, :en)
  end

  def load_translatable_item
    @person = Person.friendly.find(params[:person_id])
  end

  def translation_params
    params.require(:person).permit(:biography)
  end
end
