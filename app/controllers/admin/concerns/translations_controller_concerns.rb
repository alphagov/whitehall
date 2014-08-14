module Admin::TranslationsControllerConcerns
  extend ActiveSupport::Concern

  included do
    before_filter :load_things
  end

  def index
  end

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
end
