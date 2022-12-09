require "gds_api/router"
require "gds_api/publishing_api"

namespace :reslug do
  desc "Change a person slug (DANGER!).\n

  This rake task changes a person's slug in whitehall.

  It performs the following steps:
  - changes the person's slug
  - reindexes the person for search
  - republishes the person to Publishing API (automatically handles the redirect)
  - reindexes all dependent documents in search"
  task :person, %i[old_slug new_slug] => :environment do |_task, args|
    person = Person.find_by!(slug: args[:old_slug])
    DataHygiene::PersonReslugger.new(person, args[:new_slug]).run!
  end

  desc "Change a role slug (DANGER!).\n

  This rake task changes a roles's slug in whitehall.

  It performs the following steps:
  - changes the role's slug
  - reindexes the role for search
  - republishes the role to Publishing API (automatically handles the redirect)"
  task :role, %i[old_slug new_slug] => :environment do |_task, args|
    role = Role.find_by!(slug: args[:old_slug])
    DataHygiene::RoleReslugger.new(role, args[:new_slug]).run!
  end

  desc "Change a topical_event's slug in whitehall (DANGER!).\n
  It performs the following steps:
  - changes the topical_events slug
  - reindexes the topical_event with its new slug
  - republishes the topical_event to Publishing API (automatically handles the redirect)"
  task :topical_event, %i[old_slug new_slug] => :environment do |_task, args|
    topical_events = TopicalEvent.where(slug: args.old_slug)
    raise "Multiple topical_events with slug '#{args.old_slug}'. Use content_id to uniquely identify it." if topical_events.count > 1
    raise "No topical_event with slug '#{args.old_slug}'. Use content_id to uniquely identify it." if topical_events.count < 1

    topical_event = topical_events.first
    DataHygiene::TopicalEventReslugger.new(topical_event, args.new_slug).run!
  end

  desc "Change a html attachment's slug in whitehall and redirect old slug\n
  It performs the following steps:
  - changes a html attachment slug
  - reindexes the document
  - republishes the document and attachment to Publishing API (automatically handles the redirect)"
  task :html_attachment, %i[publication_slug old_attachment_slug new_attachment_slug] => :environment do |_task, args|
    documents = Document.where(slug: args.publication_slug)
    if documents.count > 1
      raise "There are multiple documents with the slug '#{args.publication_slug}'. Consider writing a migration and fetching the document with a content_id or document_type to uniquely identify it."
    end

    document = documents.first
    edition = document.editions.published.last
    html_attachment = edition.attachments.find_by(slug: args.old_attachment_slug)

    raise "Could not find existing attachment with slug /#{args.old_attachment_slug}" unless html_attachment

    # update slug of html attachement and add redirect
    html_attachment.update!(slug: args.new_attachment_slug)
    Whitehall::PublishingApi.republish_async(html_attachment)

    # remove the most recent edition from the search index
    Whitehall::SearchIndex.delete(edition)

    # send edition to publishing api
    PublishingApiDocumentRepublishingWorker.new.perform(document.id)

    # add edition to search index
    Whitehall::SearchIndex.add(edition)
  end

  desc "Change the slug of a PolicyGroup"
  task :policy_group, %i[old_slug new_slug] => :environment do |_task, args|
    policy_group = PolicyGroup.find_by!(slug: args.old_slug)

    Whitehall::SearchIndex.delete(policy_group)

    policy_group.update!(slug: args.new_slug)

    Whitehall::PublishingApi.republish_async(policy_group)
    Whitehall::SearchIndex.add(policy_group)
  end

  desc "Change the slug of a WorldLocation"
  task :world_location, %i[old_slug new_slug] => :environment do |_task, args|
    world_location = WorldLocation.find_by!(slug: args.old_slug)
    world_location.update!(slug: args.new_slug)
    world_location.editions.published.each(&:update_in_search_index)
  end

  desc "Change an organisation slug (DANGER!).\n

  This rake task changes the slug of an organisation in whitehall.

  It performs the following steps:
  - updates the Organisation's slug
  - republishes the org to Publishing API (which creates a redirect)
  - reindexes the org for search
  - reindexes all dependent documents in search"
  task :organisation, %i[old_slug new_slug] => :environment do |_task, args|
    organisation = Organisation.find_by!(slug: args[:old_slug])
    DataHygiene::OrganisationReslugger.new(organisation, args[:new_slug]).run!
  end

  desc "Change a worldwide organisation slug (DANGER!).\n

  This rake task changes the slug of a worldwide organisation in whitehall.

  It performs the following steps:
  - updates the WorldwideOrganisation's slug
  - republishes the org to Publishing API (which creates a redirect)
  - reindexes the org for search
  - reindexes all dependent documents in search"
  task :worldwide_organisation, %i[old_slug new_slug] => :environment do |_task, args|
    organisation = WorldwideOrganisation.find_by!(slug: args[:old_slug])
    DataHygiene::OrganisationReslugger.new(organisation, args[:new_slug]).run!
  end

  desc "Change the slug of a StatisticsAnnouncement"
  task :statistics_annoucement, %i[old_slug new_slug] => :environment do |_task, args|
    statistics_announcement = StatisticsAnnouncement.find_by!(slug: args.old_slug)
    Whitehall::SearchIndex.delete(statistics_announcement)
    statistics_announcement.update!(slug: args.new_slug)
    Whitehall::SearchIndex.add(statistics_announcement)
  end
end
