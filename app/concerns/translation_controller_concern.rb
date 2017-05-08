module TranslationControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :load_translatable_item
    before_action :load_translated_models, except: [:index]
    helper_method :translation_locale
  end

  def create
    redirect_to create_redirect_path
  end

  def update
    if translatable_item.update_attributes(translation_params)
      save_draft_translation_async if send_downstream?
      redirect_to update_redirect_path, notice: notice_message("saved")
    else
      render action: 'edit'
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
    %{#{translation_locale.english_language_name} translation for "#{translated_item_name}" #{action}.}
  end

  def save_draft_translation_async
    Whitehall::PublishingApi.save_draft_translation_async(translatable_item, translation_locale.code)
  end

  def send_downstream?
    translatable_item.respond_to?(:publish_to_publishing_api)
  end
end
