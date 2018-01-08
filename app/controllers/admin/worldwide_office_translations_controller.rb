class Admin::WorldwideOfficeTranslationsController < Admin::BaseController
  include TranslationControllerConcern

private

  def create_redirect_path
    edit_admin_worldwide_organisation_worldwide_office_translation_path(@worldwide_organisation, @worldwide_office, id: translation_locale)
  end

  def destroy_redirect_path
    admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation)
  end

  def update_redirect_path
    admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation)
  end

  def load_translatable_item
    @worldwide_organisation = WorldwideOrganisation.friendly.find(params[:worldwide_organisation_id])
    @worldwide_office = @worldwide_organisation.offices.find(params[:worldwide_office_id])
    @contact = @worldwide_office.contact
  end

  def load_translated_models
    @translated_contact = LocalisedModel.new(@contact, translation_locale.code, [:contact_numbers])
    @english_contact = LocalisedModel.new(@contact, :en, [:contact_numbers])
  end

  def translatable_item
    @translated_contact
  end

  def translated_item_name
    @contact.title
  end

  def translation_params
    params.require(:contact)
          .permit(:title, :comments, :recipient, :street_address, :locality,
                  :region, :email, :contact_form_url,
                  contact_numbers_attributes: %i[id label number])
  end
end
