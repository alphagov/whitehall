class Admin::CorporateInformationPagesTranslationsController < Admin::BaseController
  before_filter :load_translated_and_english_corporate_information_pages, except: [:index]
  helper_method :translation_locale

  def index
    @translated_locales = (corporate_information_page.translated_locales - [I18n.default_locale]).map { |l| Locale.new(l) }
    @missing_locales = Locale.non_english - @translated_locales
  end

  def create
    redirect_to [:edit, :admin, @organisational_entity, corporate_information_page, translation_locale]
  end

  def edit
  end

  def update
    if @translated_corporate_information_page.update_attributes(params[:corporate_information_page])
      redirect_to [:admin, @organisational_entity, @translated_corporate_information_page, :translations],
        notice: notice_message("saved")
    else
      render :edit
    end
  end

  def destroy
    @translated_corporate_information_page.remove_translations_for(translation_locale.code)
    redirect_to [:admin, @organisational_entity, @translated_corporate_information_page, :translations],
      notice: notice_message("deleted")
  end

  private

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{corporate_information_page.title}" #{action}.}
  end

  def load_translated_and_english_corporate_information_pages
    @translated_corporate_information_page = LocalisedModel.new(corporate_information_page, translation_locale.code)
    @english_corporate_information_page = LocalisedModel.new(corporate_information_page, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def organisational_entity
    @organisational_entity ||= if params.has_key?(:organisation_id)
        Organisation.find(params[:organisation_id])
      elsif params.has_key?(:worldwide_organisation_id)
        WorldwideOrganisation.find(params[:worldwide_organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def corporate_information_page
    @corporate_information_page ||= organisational_entity.corporate_information_pages.find(params[:corporate_information_page_id])
  end
end
