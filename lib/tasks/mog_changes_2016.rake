task mog_changes_2016: [:environment] do
  # This is an orphan StatisticsAnnouncementOrganisation that refers to a
  # statistics announcement that doesn't exist in the database.
  # Do a Where#delete_all to keep idempotency.
  StatisticsAnnouncementOrganisation.where(id: 7980).delete_all

  decc = Organisation.find_by(slug: "department-of-energy-climate-change")
  beis = Organisation.find_by(slug: "department-for-business-energy-and-industrial-strategy")
  dit = Organisation.find_by(slug: "department-for-international-trade")

  # Retag DECC -> BEIS statistics announcements.
  decc.statistics_announcement_organisations.each do |statistics_announcement_organisation|
    statistics_announcement_organisation.update_attributes!(organisation_id: beis.id)
  end

  # Republish the new ones to publishing-api
  beis.statistics_announcements.each(&:publish_to_publishing_api)

  # Republish to search (this will make them show up )
  beis.statistics_announcements.each(&:notify_search)

  mog_changes = YAML.load_file("#{Rails.root}/lib/tasks/mog_changes_2016.yml")

  # Retag documents
  retag_slugs_to_lead_organisations(mog_changes["from_decc_to_beis"], beis)
  retag_slugs_to_lead_organisations(mog_changes["from_ukti_to_dit"], dit)
  retag_slugs_to_lead_organisations(mog_changes["from_bis_to_beis"], beis)
  retag_slugs_to_lead_organisations(mog_changes["from_bis_to_dit"], dit)
end

def retag_slugs_to_lead_organisations(slugs, new_organisation)
  documents = Document.where(slug: slugs)
  documents.each do |document|
    edition = document.published_edition

    if edition
      edition.lead_organisations = [new_organisation]
      unless edition.save
        puts "[#{new_organisation.slug}] Saving #{document.slug} caused errors: #{edition.errors.full_messages}"
      end
    else
      puts "[#{new_organisation.slug}] Document #{document.inspect} doesn't have a published edition, so can't retag"
    end
  end
end
