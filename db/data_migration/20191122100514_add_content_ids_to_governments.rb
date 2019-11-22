Government.where(content_id: nil).find_each do |government|
  government.update_attribute(:content_id, SecureRandom.uuid)
end
