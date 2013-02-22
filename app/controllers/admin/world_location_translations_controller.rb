class Admin::WorldLocationTranslationsController < Admin::BaseController
  before_filter :load_translated_and_english_world_locations, except: [:index]
  helper_method :translation_locale

  def index
    @translated_locales = (world_location.translated_locales - [:en]).map {|l| Locale.new(l)}
    @missing_locales = Locale.non_english - @translated_locales
  end

  def create
    redirect_to edit_admin_world_location_translation_path(world_location, id: translation_locale)
  end

  def edit
  end

  def update
    if @translated_world_location.update_attributes(params[:world_location])
      redirect_to admin_world_location_translations_path(@translated_world_location)
    else
      render action: 'edit'
    end
  end

  def destroy
    @translated_world_location.remove_translations_for(translation_locale.code)
    redirect_to admin_world_location_translations_path(@translated_world_location)
  end

  private

  def load_translated_and_english_world_locations
    @translated_world_location = LocalisedModel.new(world_location, translation_locale.code)
    @english_world_location = LocalisedModel.new(world_location, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def world_location
    @world_location ||= WorldLocation.find(params[:world_location_id])
  end
end
