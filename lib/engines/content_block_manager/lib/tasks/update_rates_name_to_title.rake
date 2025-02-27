namespace :content_block_manager do
  desc "Change Rate key name to title"
  task change_rates_name: :environment do
    ContentBlockManager::ContentBlock::Document.where(block_type: "pension").find_each do |document|
      document.editions.each do |edition|
        edition.details["rates"]&.each do |key, value|
          next if value["name"].blank?

          puts "updating #{key} on #{edition.title}"
          edition.details["rates"][key]["title"] = value["name"]
          edition.details["rates"][key].delete("name")
        end
        edition.save!
      end
    end
  end
end
