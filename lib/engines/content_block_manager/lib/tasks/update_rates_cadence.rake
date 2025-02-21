namespace :content_block_manager do
  desc "Update Content Block Manager Version Diffs"
  task update_rates_cadence: :environment do
    ContentBlockManager::ContentBlock::Document.where(block_type: "pension").find_each do |document|
      document.editions.each do |edition|
        edition.details.dig("rates")&.each do |key, value|
          if value["cadence"] == "weekly"
            edition.details.dig("rates")[key]["cadence"] = "a week"
          elsif value["cadence"] == "monthly"
            edition.details.dig("rates")[key]["cadence"] = "a month"
          end
        end
        edition.save!
      end
    end
  end
end
