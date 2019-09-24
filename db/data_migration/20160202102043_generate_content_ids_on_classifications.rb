require "securerandom"

Classification.where(content_id: nil).each do |classification|
  classification.update_column(:content_id, SecureRandom.uuid)
end
