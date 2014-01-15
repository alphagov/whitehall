class Admin::WorldLocationTranslationsController < Admin::BaseController
  before_filter :load_world_location
  before_filter :load_translated_and_english_world_locations, except: [:index]
  helper_method :translation_locale

  def index
  end

  def create
    redirect_to edit_admin_world_location_translation_path(@world_location, id: translation_locale)
  end

  def edit
  end

  def update
    if @translated_world_location.update_attributes(world_location_params)
      redirect_to admin_world_location_translations_path(@translated_world_location),
        notice: notice_message("saved")
    else
      render action: 'edit'
    end
  end

  def destroy
    @translated_world_location.remove_translations_for(translation_locale.code)
    redirect_to admin_world_location_translations_path(@translated_world_location),
      notice: notice_message("deleted")
  end

  private

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@world_location.name}" #{action}.}
  end

  def load_translated_and_english_world_locations
    @translated_world_location = LocalisedModel.new(@world_location, translation_locale.code)
    @english_world_location = LocalisedModel.new(@world_location, :en)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def load_world_location
    @world_location ||= WorldLocation.find(params[:world_location_id])
  end

  def world_location_params
    params.require(:world_location).permit(:name, :mission_statement, :title)
  end
end
