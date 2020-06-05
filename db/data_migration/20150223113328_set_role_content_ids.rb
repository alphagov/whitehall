Role.where(content_id: nil).find_each do |role|
  role.update(content_id: SecureRandom.uuid)
end
