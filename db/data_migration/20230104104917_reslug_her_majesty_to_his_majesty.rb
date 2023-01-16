require "csv"
require "uri"

csv_file = File.join(File.dirname(__FILE__), "20230104104916_reslug_her_majesty_to_his_majesty.csv")
csv = CSV.parse(File.open(csv_file), headers: true)

csv.each do |row|
  puts "reslugging #{row['current_url']}"

  old_slug = URI(row["current_url"]).path.split("/").last
  new_slug = URI(row["new_url"]).path.split("/").last

  case row["content_type"]
  when "html_publication"
    publication_slug = URI(row["current_url"]).path.split("/").second_to_last
    documents = Document.where(slug: publication_slug)
    if documents.count > 1
      puts "There are multiple documents with the slug '#{publication_slug}'. Consider writing a migration and fetching the document with a content_id or document_type to uniquely identify it."
      next
    end

    document = documents.first
    edition = document&.live_edition
    unless edition
      puts "!! edition not found for: #{old_slug}"
      next
    end

    html_attachment = edition.attachments.find_by(slug: old_slug)

    unless html_attachment
      puts "!! no HTML attachments found for: #{old_slug}"
      next
    end

    # update slug of html attachement and add redirect
    html_attachment.update!(slug: new_slug)
    Whitehall::PublishingApi.republish_async(html_attachment)

    # remove the most recent edition from the search index
    Whitehall::SearchIndex.delete(edition)

    # send edition to publishing api
    PublishingApiDocumentRepublishingWorker.new.perform(document.id)

    # add edition to search index
    Whitehall::SearchIndex.add(edition)

  when "official_statistics_announcement"
    statistics_announcement = StatisticsAnnouncement.find_by(slug: old_slug)

    unless statistics_announcement
      puts "!! no statistics announcement found for: #{old_slug}"
      next
    end

    Whitehall::SearchIndex.delete(statistics_announcement)
    statistics_announcement.update!(slug: new_slug)
    Whitehall::SearchIndex.add(statistics_announcement)

  when "organisation"
    organisation = Organisation.find_by(slug: old_slug)

    unless organisation
      puts "!! no organisation found for: #{old_slug}"
      next
    end

    DataHygiene::OrganisationReslugger.new(organisation, new_slug).run!

  when "ministerial_role"
    role = Role.find_by!(slug: old_slug)

    unless role
      puts "!! no role found for: #{old_slug}"
      next
    end

    DataHygiene::RoleReslugger.new(role, new_slug).run!

  when "about", "complaints_procedure", "equality_and_diversity", "our_governance", "recruitment"
    puts "Corporate information pages are redirected via their organisation pages"

  else
    document = Document.find_by(slug: old_slug)

    unless document
      puts "!! no document found for: #{old_slug}"
      next
    end

    edition = document.live_edition

    unless edition
      puts "!! edition not found for: #{old_slug}"
      next
    end

    user = User.find_by(name: "Rebecca Pearce")

    DataHygiene::DocumentReslugger.new(document, edition, user, new_slug).run!
  end
  next
end
