class Admin::WorldLocationTranslationsController < Admin::BaseController
  before_filter :load_translated_and_english_world_locations, except: [:index]
  helper_method :translation_locale

  def index
    @locales = world_location.translated_locales - [:en]
  end

  def new
  end

  def create
    if @translated_world_location.update_attributes(params[:world_location])
      redirect_to admin_world_location_translations_path(@translated_world_location)
    else
      render action: 'new'
    end
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

  private

  def load_translated_and_english_world_locations
    @translated_world_location = LocalisedModel.new(world_location, translation_locale)
    @english_world_location = LocalisedModel.new(world_location, :en)
  end

  def translation_locale
    @translation_locale ||= params[:translation_locale] || params[:id]
  end

  def world_location
    @world_location ||= WorldLocation.find(params[:world_location_id])
  end
end
