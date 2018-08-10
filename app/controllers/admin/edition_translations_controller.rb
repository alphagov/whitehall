class Admin::EditionTranslationsController < Admin::BaseController
  include TranslationControllerConcern

  def update
    @translated_edition.change_note = 'Added translation' unless @translated_edition.change_note.present?
    super
  end

private

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
    @edition_remarks = @edition.document_remarks_trail.reverse
    @edition_history = Kaminari.paginate_array(@edition.document_version_trail.reverse).page(params[:page]).per(30)
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
