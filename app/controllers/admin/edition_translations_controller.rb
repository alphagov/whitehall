class Admin::EditionTranslationsController < Admin::BaseController
  before_filter :find_edition
  before_filter :fetch_edition_version_and_remark_trails, only: [:new, :create, :edit, :update]
  before_filter :enforce_permissions!
  before_filter :limit_edition_access!
  before_filter :load_translated_and_english_edition, only: [:edit, :update, :destroy]
  helper_method :translation_locale

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end

  def create
    redirect_to edit_admin_edition_translation_path(@edition, id: translation_locale)
  end

  def edit
  end

  def update
    @translated_edition.change_note = 'Added translation' unless @translated_edition.change_note.present?
    if @translated_edition.update_attributes(params[:edition])
      redirect_to admin_edition_path(@edition),
        notice: notice_message("saved")
    else
      render :edit
    end
  end

  def destroy
    @translated_edition.remove_translations_for(translation_locale.code)
    redirect_to admin_edition_path(@translated_edition),
      notice: notice_message("deleted")
  end

  private

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@edition.title}" #{action}.}
  end

  def load_translated_and_english_edition
    @translated_edition = LocalisedModel.new(@edition, translation_locale.code)
    @english_edition = LocalisedModel.new(@edition, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def find_edition
    @edition ||= Edition.find(params[:edition_id])
  end

  def fetch_edition_version_and_remark_trails
    @edition_remarks = @edition.document_remarks_trail.reverse
    @edition_history = Kaminari.paginate_array(@edition.document_version_trail.reverse).page(params[:page]).per(30)
  end
end

