class Admin::ContactTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcerns

  before_filter :find_contactable, :find_contact
  before_filter :load_translated_and_english_contact, except: :create
  helper_method :translation_locale

private

  def create_redirect_path
    edit_admin_organisation_contact_translation_path(@contactable, @contact, id: translation_locale)
  end

  def update_attributes
    @translated_contact.update_attributes(contact_params)
  end

  def update_redirect_path
    admin_organisation_contacts_path(@contactable)
  end

  def remove_translations
    @contact.remove_translations_for(translation_locale.code)
  end

  def destroy_redirect_path
    admin_organisation_contacts_path(@contactable)
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

  def translated_thing
    @contact.title
  end

  def contact_params
    params.require(:contact).permit(
      :title, :comments, :recipient, :street_address, :locality, :region,
      :email, :contact_form_url,
      contact_numbers_attributes: [:id, :label, :number]
    )
  end
end
