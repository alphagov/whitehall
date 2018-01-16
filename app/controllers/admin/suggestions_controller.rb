class Admin::SuggestionsController < Admin::BaseController
  def index
    org_contacts = Contact.where(contactable_type: 'organisation').includes(:translations, contactable: :translations)
    world_contacts = Contact.where(contactable_type: 'WorldwideOffice').includes(:translations, contactable: { worldwide_organisation: :translations })
    @contacts = (org_contacts + world_contacts).map do |contact|
      {
        id: contact.id,
        title: contact.title,
        summary: contact.contactable_name
      }
    end
    respond_to do |format|
      format.json do
        render json: { contacts: @contacts }
      end
    end
  end
end
