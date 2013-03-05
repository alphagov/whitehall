module ContactsHelper
  def render_hcard_address(contact)
    AddressFormatter::HCard.from_contact(contact).render
  end
end
