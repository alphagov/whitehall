Government.where(content_id: nil).find_each do |government|
  government.update(content_id: SecureRandom.uuid)
end
