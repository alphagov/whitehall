class Admin::EditionTranslationsController < Admin::BaseController
  include TranslationControllerConcern
  layout :get_layout
  before_action :forbid_editing_of_locked_documents

  def new
    render "legacy_new" unless preview_design_system_user?
  end

  def edit
    render "edit_legacy" unless preview_design_system_user?
  end

  def update
    @translated_edition.change_note = "Added translation" if @translated_edition.change_note.blank?
    if translatable_item.update(translation_params)
      save_draft_translation if send_downstream?
      redirect_to update_redirect_path, notice: notice_message("saved")
    else
      render action: preview_design_system_user? ? "edit" : "edit_legacy"
    end
  end

private

  def get_layout
    return "admin" unless preview_design_system_user?

    case action_name
    when "edit", "update", "new"
      "design_system"
    else
      "admin"
    end
  end

  def create_redirect_path
    edit_admin_edition_translation_path(@edition, id: translation_locale)
  end

  def destroy_redirect_path
    admin_edition_path(@translated_edition)
  end

  def update_redirect_path
    admin_edition_path(@edition)
  end

  def translatable_item
    @translated_edition
  end

  def translated_item_name
    @edition.title
  end

  def load_translated_models
    @document_remarks = Document::PaginatedRemarks.new(@edition.document, params[:remarks_page])
    @document_history = Document::PaginatedHistory.new(@edition.document, params[:page])
    @translated_edition = LocalisedModel.new(@edition, translation_locale.code)
  end

  def load_translatable_item
    @edition ||= Edition.find(params[:edition_id])
    enforce_permission!(:update, @edition)
    limit_edition_access!
  end

  def translation_params
    params.require(:edition).permit(:title, :summary, :body)
  end

  def save_draft_translation
    Whitehall.edition_services.draft_translation_updater(translatable_item, locale: translation_locale.code).perform!
  end

  def send_downstream?
    true
  end
end
