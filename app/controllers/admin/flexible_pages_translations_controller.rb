class Admin::FlexiblePagesTranslationsController < Admin::BaseController
  include TranslationControllerConcern

  before_action :build_translation_locale, only: %i[confirm_destroy]
  before_action :create_content_block_context

  def edit
    load_document_history
    render "admin/flexible_pages/_translations", locals: {
      edition: @edition,
      primary_locale: false,
      locale: translation_locale.code,
    }
  end

  def update
    if translatable_item.update(translation_params)
      save_draft_translation
      redirect_to update_redirect_path, notice: notice_message("saved")
    else
      load_document_history
      render :edit
    end
  end

private

  def update_redirect_path
    admin_flexible_page_path(@edition)
  end

  def translatable_item
    @translated_edition
  end

  def translated_item_name
    @edition.title
  end

  def load_translated_models
    @translated_edition = LocalisedModel.new(@edition, translation_locale.code)
  end

  def load_translatable_item
    @edition = Edition.find(params[:flexible_page_id])
  end

  def create_content_block_context
    FlexiblePageContentBlocks::Context.create_for_page(@translated_edition)
  end

  def translation_params
    params.require(:edition).permit(
      :lock_version,
      :title,
      :flexible_page_type,
      flexible_page_content: {},
    )
  end

  def save_draft_translation
    Whitehall.edition_services.draft_translation_updater(translatable_item, locale: translation_locale.code).perform!
  end

  def load_document_history
    @document_history = Document::PaginatedTimeline.new(document: @edition.document, page: params[:page] || 1, only: params[:only])
  end
end
