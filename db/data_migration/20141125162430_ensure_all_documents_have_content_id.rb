Document.where(content_id: nil).find_each do |document|
  document.update(content_id: SecureRandom.uuid)
end
