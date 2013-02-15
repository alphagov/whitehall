class Admin::EditionTranslationsController < Admin::BaseController
  before_filter :load_translated_and_english_edition, only: [:edit, :update]
  helper_method :translation_locale

  def create
    redirect_to edit_admin_edition_translation_path(edition, id: translation_locale)
  end

  def edit
  end

  def update
    @translated_edition.change_note = 'Added translation' unless @translated_edition.change_note.present?
    if @translated_edition.update_attributes(params[:edition])
      redirect_to admin_edition_path(edition)
    else
      render :edit
    end
  end

  private

  def load_translated_and_english_edition
    @translated_edition = LocalisedModel.new(edition, translation_locale.code)
    @english_edition = LocalisedModel.new(edition, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def edition
    @edition ||= Edition.find(params[:edition_id])
  end
end