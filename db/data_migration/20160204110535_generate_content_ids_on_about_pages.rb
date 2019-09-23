require "securerandom"

AboutPage.where(content_id: nil).each do |about_page|
  about_page.update_column(:content_id, SecureRandom.uuid)
end
