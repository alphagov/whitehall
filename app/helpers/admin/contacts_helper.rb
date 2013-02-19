module Admin::ContactsHelper
  def contacts_list_url_for(contactable)
    case contactable
    when Organisation
      url_for(controller: :organisations, action: :show, id: contactable, anchor: 'contacts')
    when WorldwideOrganisation
      url_for(controller: :worldwide_organisations, action: :contacts, id: contactable)
    else
      url_for([:admin, contactable])
    end
  end
end