module Admin::ContactsHelper
  def contacts_list_url_for(contactable)
    case contactable
    when Organisation
      url_for(controller: :organisations, action: :show, id: contactable, anchor: 'contacts')
    when WorldwideOffice
      url_for(controller: :worldwide_offices, action: :contacts, id: contactable)
    else
      url_for([:admin, contactable])
    end
  end
end