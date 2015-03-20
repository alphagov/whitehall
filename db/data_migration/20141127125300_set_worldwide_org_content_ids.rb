WorldwideOrganisations.where(content_id: nil).find_each do |worldwide_organisation|
  worldwide_organisation.update_attribute(:content_id, SecureRandom.uuid)
end
