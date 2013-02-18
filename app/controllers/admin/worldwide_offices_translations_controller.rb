class Admin::WorldwideOfficesTranslationsController < Admin::BaseController
  before_filter :load_translated_and_english_worldwide_offices, except: [:index]
  helper_method :translation_locale

  def index
    @translated_locales = (worldwide_office.translated_locales - [:en]).map {|l| Locale.new(l)}
    @missing_locales = Locale.non_english - @translated_locales
  end

  def create
    redirect_to edit_admin_worldwide_office_translation_path(worldwide_office, id: translation_locale)
  end

  def edit
  end

  def update
    if @translated_worldwide_office.update_attributes(params[:worldwide_office])
      redirect_to admin_worldwide_office_translations_path(@translated_worldwide_office)
    else
      render action: 'edit'
    end
  end

  private

  def load_translated_and_english_worldwide_offices
    @translated_worldwide_office = LocalisedModel.new(worldwide_office, translation_locale.code)
    @english_worldwide_office = LocalisedModel.new(worldwide_office, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def worldwide_office
    @worldwide_office ||= WorldwideOffice.find(params[:worldwide_office_id])
  end
end
