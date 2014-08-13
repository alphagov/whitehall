module Admin::TranslationsControllerConcerns
  extend ActiveSupport::Concern

  def create
    redirect_to create_redirect_path
  end

  def edit
  end

  def update
    if update_attributes
      redirect_to update_redirect_path, notice: notice_message("saved")
    else
      render action: 'edit'
    end
  end

  def destroy
    remove_translations
    redirect_to destroy_redirect_path, notice: notice_message("deleted")
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{translated_thing}" #{action}.}
  end

  def translated_thing
    raise
  end

  def create_redirect_path
    raise "create_redirect_path should be overridden in the including controller"
  end

  def update_attributes
    raise "update_attributes should be overridden in the including controller"
  end

  def update_redirect_path
    raise "update_redirect_path should be overridden in the including controller"
  end

  def remove_translations
    raise
  end

  def destroy_redirect_path
    raise
  end
end
