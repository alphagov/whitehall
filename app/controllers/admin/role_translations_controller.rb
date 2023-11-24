class Admin::RoleTranslationsController < Admin::BaseController
  include TranslationControllerConcern

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

  def translated_item_name
    @role.name
  end

  def load_translated_models
    @translated_role = LocalisedModel.new(@role, translation_locale.code)
    @english_role = LocalisedModel.new(@role, :en)
  end

  def load_translatable_item
    @role = Role.find(params[:role_id])
  end

  def translation_params
    params.require(:role).permit(:name, :responsibilities)
  end
end
