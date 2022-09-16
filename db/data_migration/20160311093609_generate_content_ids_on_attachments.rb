require "securerandom"

Attachment.where(content_id: nil).pluck(:id).each do |id|
  print "."
  Attachment.where(id:).update_all(content_id: SecureRandom.uuid)
end
