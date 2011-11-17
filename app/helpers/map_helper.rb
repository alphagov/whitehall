module MapHelper
  def link_to_google_map(organisation)
    if organisation.latitude and organisation.longitude
      link_to "View map", "http://maps.google.co.uk/maps?q=#{organisation.latitude},#{organisation.longitude}"
    elsif organisation.postcode
      link_to "View map", "http://maps.google.co.uk/maps?q=#{organisation.postcode}"
    end
  end
end