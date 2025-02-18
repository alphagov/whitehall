namespace :content_block_manager do
  desc "Update Content Block Manager Version Diffs"
  task update_version_diffs: :environment do
    ContentBlockManager::ContentBlock::Version.where(event: "updated", item_type: "ContentBlockManager::ContentBlock::Edition").find_each do |version|
      edition = version.item
      previous_edition = edition.document.editions.includes(:edition_organisation, :organisation)
                            .where("created_at < ?", edition.created_at)
                            .order(created_at: :asc)
                            .last
      next if previous_edition.nil?

      edition.previous_edition = previous_edition
      version.field_diffs = edition.generate_diff
      version.save!
    end
  end
end
