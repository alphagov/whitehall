class Admin::EditionTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcern

  before_filter :fetch_edition_version_and_remark_trails, only: [:new, :create, :edit, :update]
  before_filter :load_translated_and_english_edition, only: [:edit, :update, :destroy]
  before_filter :limit_edition_access!
  helper_method :translation_locale

  private

  def create_redirect_path
    edit_admin_edition_translation_path(@edition, id: translation_locale)
  end

  def update_attributes
    @translated_edition.change_note = 'Added translation' unless @translated_edition.change_note.present?
    @translated_edition.update_attributes(edition_params)
  end

  def remove_translations
    @translated_edition.remove_translations_for(translation_locale.code)
  end

  def destroy_redirect_path
    admin_edition_path(@translated_edition)
  end

  def update_redirect_path
    admin_edition_path(@edition)
  end

  def translated_item
    @edition.title
  end

  def load_translated_and_english_edition
    @translated_edition = LocalisedModel.new(@edition, translation_locale.code)
    @english_edition = LocalisedModel.new(@edition, :en)
  end

  def load_translatable_items
    @edition ||= Edition.find(params[:edition_id])
    enforce_permission!(:update, @edition)
  end


  def fetch_edition_version_and_remark_trails
    @edition_remarks = @edition.document_remarks_trail.reverse
    @edition_history = Kaminari.paginate_array(@edition.document_version_trail.reverse).page(params[:page]).per(30)
  end

  def edition_params
    params.require(:edition).permit(:title, :summary, :body)
  end
end
