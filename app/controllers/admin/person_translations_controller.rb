class Admin::PersonTranslationsController < Admin::BaseController
  before_filter :load_person
  before_filter :load_translated_and_english_people, except: [:index]
  helper_method :translation_locale

  def index
  end

  def create
    redirect_to edit_admin_person_translation_path(@person, id: translation_locale)
  end

  def edit
  end

  def update
    if @translated_person.update_attributes(person_params)
      redirect_to admin_person_translations_path(@translated_person),
        notice: notice_message("saved")
    else
      render action: 'edit'
    end
  end

  def destroy
    @translated_person.remove_translations_for(translation_locale.code)
    redirect_to admin_person_translations_path(@translated_person),
      notice: notice_message("deleted")
  end

  private

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
