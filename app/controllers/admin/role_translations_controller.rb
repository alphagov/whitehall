class Admin::RoleTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcern

  before_filter :load_translated_and_english_roles, except: [:index]
  helper_method :translation_locale

  private

  def create_redirect_path
    edit_admin_role_translation_path(@role, id: translation_locale)
  end

  def destroy_redirect_path
    admin_role_translations_path(@translated_role)
  end

  def update_redirect_path
    admin_role_translations_path(@translated_role)
  end

  def translatable_item
    @translated_role
  end

  def translated_item
    @role.name
  end

  def load_translated_and_english_roles
    @translated_role = LocalisedModel.new(@role, translation_locale.code)
    @english_role = LocalisedModel.new(@role, :en)
  end

  def load_translatable_items
    @role ||= Role.find(params[:role_id])
  end

  def translation_params
    params.require(:role).permit(:name, :responsibilities)
  end
end
