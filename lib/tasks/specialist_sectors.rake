# Fix specialist sectors that have lost their tags as a result of names etc
# being changed. This results in the specialist sectors displaying as blank
# whereas they are actually still attached via the `topic_content_id`.
namespace :specialist_sectors do
  desc "Sync specialist sector tags with publishing-api"
  task sync_tags: :environment do
    specialist_sectors = SpecialistSector.where(tag: nil)
    specialist_sectors.each do |specialist_sector|
      begin
        content_item = Services.publishing_api.get_content(
          specialist_sector.topic_content_id
        ).to_hash
      rescue GdsApi::HTTPNotFound
        # Some incorrect specialist sectors have base paths rather than
        # content IDs, so we skip these for now
        next
      end
      new_tag = content_item['base_path'].sub('/topic/', '')
      puts "Updating specialist sector #{specialist_sector.id} with tag #{new_tag}"
      specialist_sector.tag = new_tag
      specialist_sector.save!
    end
  end
end
