class Admin::WorldLocationTranslationsController < Admin::BaseController
  include TranslationControllerConcern

private

  def create_redirect_path
    edit_admin_world_location_translation_path(@world_location, id: translation_locale)
  end

  def destroy_redirect_path
    admin_world_location_translations_path(@translated_world_location)
  end

  def update_redirect_path
    admin_world_location_translations_path(@translated_world_location)
  end

  def translatable_item
    @translated_world_location
  end

  def translated_item_name
    @world_location.name
  end

  def load_translated_models
    @translated_world_location = LocalisedModel.new(@world_location, translation_locale.code)
    @english_world_location = LocalisedModel.new(@world_location, :en)
  end

  def load_translatable_item
    @world_location = WorldLocation.friendly.find(params[:world_location_id])
  end

  def translation_params
    params.require(:world_location).permit(:name, :mission_statement, :title)
  end
end
