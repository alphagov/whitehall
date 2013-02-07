class Admin::WorldLocationTranslationsController < Admin::BaseController
  before_filter :load_world_location
  before_filter :set_translation_locale, except: :index

  def index
  end

  def new
  end

  def create
    I18n.with_locale(@translation_locale) do
      if @world_location.update_attributes(params[:world_location])
        redirect_to admin_world_location_translations_path(@world_location)
      else
        render action: 'new'
      end
    end
  end

  private

  def load_world_location
    @world_location = WorldLocation.find(params[:world_location_id])
  end

  def set_translation_locale
    @translation_locale = params[:translation_locale]
  end
end
