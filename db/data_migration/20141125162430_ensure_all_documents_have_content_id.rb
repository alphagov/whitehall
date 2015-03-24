Document.where(content_id: nil).find_each do |document|
  document.update_attribute(:content_id, SecureRandom.uuid)
end
