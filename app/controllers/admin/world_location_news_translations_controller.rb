class Admin::WorldLocationNewsTranslationsController < Admin::BaseController
  include TranslationControllerConcern
  layout :get_layout

  def destroy
    translatable_item.world_location.remove_translations_for(translation_locale.code)
    super
  end

private

  def get_layout
    "admin"
  end

  def create_redirect_path
    edit_admin_world_location_news_translation_path(@world_location_news, id: translation_locale)
  end

  def destroy_redirect_path
    admin_world_location_news_translations_path(@translated_world_location_news)
  end

  def update_redirect_path
    admin_world_location_news_translations_path(@translated_world_location_news)
  end

  def translatable_item
    @translated_world_location_news
  end

  def translated_item_name
    @world_location_news.world_location.name
  end

  def load_translated_models
    @translated_world_location_news = LocalisedModel.new(@world_location_news, translation_locale.code)
    @english_world_location_news = LocalisedModel.new(@world_location_news, :en)

    @translated_world_location = LocalisedModel.new(@world_location_news.world_location, translation_locale.code)
    @english_world_location = LocalisedModel.new(@world_location_news.world_location, :en)
  end

  def load_translatable_item
    @world_location_news = WorldLocation.friendly.find(params[:world_location_news_id]).world_location_news
  end

  def translation_params
    params.require(:world_location_news).permit(
      :mission_statement, :title,
      world_location_attributes: %i[id name]
    )
  end
end
