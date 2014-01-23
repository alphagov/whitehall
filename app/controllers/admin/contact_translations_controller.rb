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
    if @translated_contact.update_attributes(contact_params)
      redirect_to admin_organisation_contacts_path(@contactable),
                  notice: notice_message("saved")
    else
      render action: "edit"
    end
  end

  def destroy
    @contact.remove_translations_for(translation_locale.code)
    redirect_to admin_organisation_contacts_path(@contactable),
                notice: notice_message("deleted")
  end

private
  def translation_locale
    Locale.new(params[:translation_locale] || params[:id])
  end

  def find_contactable
    @contactable = Organisation.find(params[:organisation_id])
  end

  def find_contact
    @contact = @contactable.contacts.find(params[:contact_id])
  end

  def load_translated_and_english_contact
    @translated_contact = LocalisedModel.new(@contact, translation_locale.code, [:contact_numbers])
    @english_contact = LocalisedModel.new(@contact, :en, [:contact_numbers])
  end

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@contact.title}" #{action}.}
  end

  def contact_params
    params.require(:contact).permit(
      :title, :comments, :recipient, :street_address, :locality, :region,
      :email, :contact_form_url,
      contact_numbers_attributes: [:id, :label, :number]
    )
  end
end
