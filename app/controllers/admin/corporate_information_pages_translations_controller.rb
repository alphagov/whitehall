class Admin::CorporateInformationPagesTranslationsController < Admin::BaseController
  before_filter :load_translated_and_english_corporate_information_pages, except: [:index]
  helper_method :translation_locale

  def index
    @translated_locales = (corporate_information_page.translated_locales - [I18n.default_locale]).map {|l| Locale.new(l)}
    @missing_locales = Locale.non_english - @translated_locales
  end

  def create
    redirect_to url_for(action: 'edit', id: translation_locale)
  end

  def edit
  end

  def update
    if @translated_corporate_information_page.update_attributes(params[:corporate_information_page])
      redirect_to url_for(action: 'index', corporate_information_page_id: @translated_corporate_information_page),
        notice: notice_message("saved")
    else
      render action: 'edit'
    end
  end

  def destroy
    @translated_corporate_information_page.remove_translations_for(translation_locale.code)
    redirect_to url_for(action: 'index', corporate_information_page_id: @translated_corporate_information_page),
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

  def worldwide_organisation
    @worldwide_organisation ||= WorldwideOrganisation.find(params[:worldwide_organisation_id])
  end

  def corporate_information_page
    @corporate_information_page ||= worldwide_organisation.corporate_information_pages.for_slug!(params[:corporate_information_page_id])
  end
end
