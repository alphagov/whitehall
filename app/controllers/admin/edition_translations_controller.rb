class Admin::EditionTranslationsController < Admin::BaseController
  before_filter :load_translated_edition, only: [:new, :create]
  helper_method :translation_locale

  def new
  end

  def create
    @translated_edition.change_note = 'Added translation' unless @translated_edition.change_note.present?
    if @translated_edition.update_attributes(params[:edition])
      redirect_to admin_edition_path(edition)
    else
      render :new
    end
  end

  private

  def load_translated_edition
    @translated_edition = LocalisedModel.new(edition, translation_locale)
  end

  def translation_locale
    @translation_locale ||= params[:translation_locale]
  end

  def edition
    @edition ||= Edition.find(params[:edition_id])
  end
end