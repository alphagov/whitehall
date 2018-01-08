puts "Destroying corporate information pages without an owning organisation"

orphaned_cip_ids = CorporateInformationPage.pluck(:id) -
  CorporateInformationPage.joins(:organisation).pluck(:id) -
  CorporateInformationPage.joins(:worldwide_organisation).pluck(:id)

CorporateInformationPage.where(id: orphaned_cip_ids).map { |cip| cip.document.try(:destroy) } # also deletes editions

puts "Deleted #{orphaned_cip_ids.count} orphaned corporate information page editions having ids: #{orphaned_cip_ids.to_sentence}"
