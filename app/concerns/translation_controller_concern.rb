module TranslationControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :load_translatable_item
    before_action :load_translated_models, except: %i[index new]
    helper_method :translation_locale
  end

  def edit
    render :legacy_edit if get_layout == "admin" && translatable_item.is_a?(Person)
  end

  def create
    redirect_to create_redirect_path
  end

  def update
    if translatable_item.update(translation_params)
      save_draft_translation if send_downstream?
      redirect_to update_redirect_path, notice: notice_message("saved")
    elsif get_layout == "admin" && translatable_item.is_a?(Person)
      render :legacy_edit
    else
      render :edit
    end
  end

  def destroy
    translatable_item.remove_translations_for(translation_locale.code)
    redirect_to destroy_redirect_path, notice: notice_message("deleted")
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def notice_message(action)
    %(#{translation_locale.english_language_name} translation for "#{translated_item_name}" #{action}.)
  end

  def save_draft_translation
    Whitehall::PublishingApi.save_draft_translation(translatable_item, translation_locale.code)
  end

  def send_downstream?
    translatable_item.respond_to?(:publish_to_publishing_api)
  end
end
