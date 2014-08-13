class Admin::WorldLocationTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcerns

  before_filter :load_world_location
  before_filter :load_translated_and_english_world_locations, except: [:index]
  helper_method :translation_locale

  def index
  end

  private

  def create_redirect_path
    edit_admin_world_location_translation_path(@world_location, id: translation_locale)
  end

  def update_attributes
    @translated_world_location.update_attributes(world_location_params)
  end

  def remove_translations
    @translated_world_location.remove_translations_for(translation_locale.code)
  end

  def destroy_redirect_path
    admin_world_location_translations_path(@translated_world_location)
  end

  def update_redirect_path
    admin_world_location_translations_path(@translated_world_location)
  end

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@world_location.name}" #{action}.}
  end

  def load_translated_and_english_world_locations
    @translated_world_location = LocalisedModel.new(@world_location, translation_locale.code)
    @english_world_location = LocalisedModel.new(@world_location, :en)
  end

  def load_world_location
    @world_location ||= WorldLocation.find(params[:world_location_id])
  end

  def world_location_params
    params.require(:world_location).permit(:name, :mission_statement, :title)
  end
end
