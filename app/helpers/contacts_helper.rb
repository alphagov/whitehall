module ContactsHelper
  def render_hcard_address(contact)
    HCardAddress.from_contact(contact).render
  end
end
