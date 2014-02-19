require 'csv'

class ValidationSkippingPublisher < EditionForcePublisher
  def failure_reason
    nil
  end

private
  def fire_transition!
    edition.force_publish
    edition.force_published = false
    edition.save(validate: false)
    supersede_previous_editions!
  end
end

logger = Logger.new(STDOUT)

gds_user = User.find_by_name!('GDS Inside Government Team')
Edition::AuditTrail.whodunnit = gds_user

CSV.foreach("#{Rails.root}/db/data_migration/20140218160951_ukvi_guidance_mapped_to_specialist_topics.csv", {headers: true}) do |row|

  slug = row['govuk_url'].scan(/\/([^\/]*)$/)[0][0]
  logger.info "\tLooking for #{slug}"
  doc = Document.where(slug: slug).first

  sector_name = "immigration-operational-guidance/#{row['sector']}"

  unless doc
    logger.info "\tCan't find #{row['name']} document with slug #{slug}: skipping."
    next
  end
  
  logger.info("\tFound #{row['name']} document")  
    
  if doc.published_edition && doc.published_edition.is_latest_edition? 

    edition = doc.published_edition.create_draft(gds_user)
    edition.minor_change = true

    sectors = edition.specialist_sectors
    sectors += [sector_name]
    sectors = sectors.uniq
    edition.specialist_sector_tags=(sectors)

    publisher = ValidationSkippingPublisher.new(edition)
    publisher.perform!

    logger.info "\t\tPublished new detailed guide edition: #{edition.id} with sector tag of #{sector_name}"
  else

    edition = doc.latest_edition

    sectors = edition.specialist_sectors
    sectors += [sector_name]
    sectors = sectors.uniq
    edition.specialist_sector_tags=(sectors)
    edition.save

    logger.info "\t\tUpdated edition: #{edition.id}"    
  end

  edition.editorial_remarks.create!(
    body: "This change tags #{row['name']} with the specialist sector of #{sector_name}.",
    author: gds_user
  )
  logger.info "\t\tCreated editorial remark on edition"

end
