People.where(content_id: nil).find_each do |people|
  people.update_attribute(:content_id, SecureRandom.uuid)
end
