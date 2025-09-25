class Admin::StandardEditionTranslationsController < Admin::BaseController
  before_action :load_translatable_item
  before_action :load_translated_models, except: %i[index new]
  helper_method :translation_locale

  before_action :prevent_modification_of_unmodifiable_edition

  def edit
    load_document_history
  end

  def update
    @translated_edition.change_note = "Added translation" if @translated_edition.change_note.blank?
    if @translated_edition.update(translation_params)
      save_draft_translation # TODO: revise - removed send_downstream?
      redirect_to admin_standard_edition_path(@edition), notice: notice_message("saved")
    else
      load_document_history
      render :edit
    end
  end

private

  def translation_params
    params.require(:edition).permit(
      :title,
      :summary,
      block_content: {},
    )
  end

  def load_translatable_item
    @edition ||= Edition.find(params[:standard_edition_id])
    enforce_permission!(:update, @edition)
    limit_edition_access!
  end

  def load_translated_models
    @translated_edition = LocalisedModel.new(@edition, translation_locale.code)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def load_document_history
    @document_history = Document::PaginatedTimeline.new(document: @edition.document, page: params[:page] || 1, only: params[:only])
  end

  def save_draft_translation
    Whitehall::PublishingApi.save_draft_translation(@translated_edition, translation_locale.code)
  end

  def notice_message(action)
    %(#{translation_locale.english_language_name} translation for "#{@edition.title}" #{action}.)
  end
end
