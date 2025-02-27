namespace :content_block_manager do
  desc "Change Rate key cadence to frequency"
  task change_rates_cadence: :environment do
    ContentBlockManager::ContentBlock::Document.where(block_type: "pension").find_each do |document|
      document.editions.each do |edition|
        edition.details["rates"]&.each do |key, value|
          next if value["cadence"].blank?

          puts "updating #{key} on #{edition.title}"
          edition.details["rates"][key]["frequency"] = value["cadence"]
          edition.details["rates"][key].delete("cadence")
        end
        edition.save!
      end
    end
  end
end
