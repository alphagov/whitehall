class Admin::RoleTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcerns

  before_filter :load_role
  before_filter :load_translated_and_english_roles, except: [:index]
  helper_method :translation_locale

  def index
  end

  def update
    if @translated_role.update_attributes(role_params)
      redirect_to admin_role_translations_path(@translated_role),
        notice: notice_message("saved")
    else
      render action: 'edit'
    end
  end

  def destroy
    @translated_role.remove_translations_for(translation_locale.code)
    redirect_to admin_role_translations_path(@translated_role),
      notice: notice_message("deleted")
  end

  private

  def create_redirect_path
    edit_admin_role_translation_path(@role, id: translation_locale)
  end

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@role.name}" #{action}.}
  end

  def load_translated_and_english_roles
    @translated_role = LocalisedModel.new(@role, translation_locale.code)
    @english_role = LocalisedModel.new(@role, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def load_role
    @role ||= Role.find(params[:role_id])
  end

  def role_params
    params.require(:role).permit(:name, :responsibilities)
  end
end
