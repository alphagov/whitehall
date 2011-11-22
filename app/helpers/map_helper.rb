module MapHelper
  def link_to_google_map(organisation)
    if organisation.latitude and organisation.longitude
      link_to "View map", "http://maps.google.co.uk/maps?q=#{organisation.latitude},#{organisation.longitude}", class: "link_to_map"
    elsif organisation.postcode
      link_to "View map", "http://maps.google.co.uk/maps?q=#{organisation.postcode}", class: "link_to_map"
    end
  end
end