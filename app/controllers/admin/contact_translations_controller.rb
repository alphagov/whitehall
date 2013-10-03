class Admin::ContactTranslationsController < Admin::BaseController
  before_filter :find_contactable, :find_contact
  before_filter :load_translated_and_english_contact, except: :create
  helper_method :translation_locale

  def create
    redirect_to edit_admin_organisation_contact_translation_path(@contactable, @contact, id: translation_locale)
  end

  def edit
  end

  def update
    if @translated_contact.update_attributes(params[:contact])
      redirect_to admin_organisation_contacts_path(@contactable),
                  notice: notice_message("saved")
    else
      render action: "edit"
    end
  end

private
  def translation_locale
    Locale.new(params[:translation_locale] || params[:id])
  end

  def find_contactable
    @contactable =
      if params.has_key?(:organisation_id)
        Organisation.find(params[:organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def find_contact
    @contact = @contactable.contacts.find(params[:contact_id])
  end

  def load_translated_and_english_contact
    @translated_contact = LocalisedModel.new(@contact, translation_locale.code)
    @english_contact = LocalisedModel.new(@contact, :en)
  end

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@contact.title}" #{action}.}
  end
end
