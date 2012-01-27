module MapHelper
  def link_to_google_map(contact)
    if contact.latitude.present? and contact.longitude.present?
      link_to "View map", "http://maps.google.co.uk/maps?q=#{contact.latitude},#{contact.longitude}", class: "link_to_map"
    elsif contact.postcode.present?
      link_to "View map", "http://maps.google.co.uk/maps?q=#{contact.postcode}", class: "link_to_map"
    end
  end
end