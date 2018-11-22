require 'gds_api/router'
require 'gds_api/publishing_api'

namespace :reslug do
  desc "Change a person slug (DANGER!).\n

  This rake task changes a person's slug in whitehall.

  It performs the following steps:
  - changes the person's slug
  - reindexes the person for search
  - republishes the person to Publishing API (automatically handles the redirect)
  - reindexes all dependent documents in search"
  task :person, %i[old_slug new_slug] => :environment do |_task, args|
    old_slug = args[:old_slug]
    new_slug = args[:new_slug]
    person = Person.find_by!(slug: old_slug)

    DataHygiene::PersonReslugger.new(person, new_slug).run!
  end

  desc "Change a role slug (DANGER!).\n

  This rake task changes a roles's slug in whitehall.

  It performs the following steps:
  - changes the role's slug
  - reindexes the role for search
  - republishes the role to Publishing API (automatically handles the redirect)"
  task :role, %i[old_slug new_slug] => :environment do |_task, args|
    old_slug = args[:old_slug]
    new_slug = args[:new_slug]
    role = Role.find_by!(slug: old_slug)

    DataHygiene::RoleReslugger.new(role, new_slug).run!
  end

  desc "Change a document's slug in whitehall (DANGER!).\n
  It performs the following steps:
  - changes the documents slug
  - reindexes the document with it's new slug
  - republishes the document to Publishing API (automatically handles the redirect)"
  task :document, %i[old_slug new_slug] => :environment do |_task, args|
    documents = Document.where(slug: args.old_slug)
    if documents.count > 1
      raise "There are multiple documents with the slug '#{args.old_slug}'. Consider writing a migration and fetching the document with a content_id or document_type to uniquely identify it."
    end

    document = documents.first
    # remove the most recent edition from the search index
    edition = document.editions.published.last
    Whitehall::SearchIndex.delete(edition)

    # change the slug of the document and create a redirect from the original
    document.update_attributes!(slug: args.new_slug)

    # send edition to publishing api
    PublishingApiDocumentRepublishingWorker.new.perform(document.id)

    # add edition to search index
    Whitehall::SearchIndex.add(edition)
  end

  desc "Change the slug of a PolicyGroup"
  task :policy_group, %i[old_slug new_slug] => :environment do |_task, args|
    policy_group = PolicyGroup.find_by!(slug: args.old_slug)

    Whitehall::SearchIndex.delete(policy_group)

    policy_group.update_attributes!(slug: args.new_slug)

    Whitehall::PublishingApi.republish_async(policy_group)
    Whitehall::SearchIndex.add(policy_group)
  end

  desc "Change an organisation slug (DANGER!).\n

  This rake task changes the slug of an organisation in whitehall.

  It performs the following steps:
  - updates the Organisation's slug
  - republishes the org to Publishing API (which creates a redirect)
  - reindexes the org for search
  - reindexes all dependent documents in search"
  task :organisation, %i[old_slug new_slug] => :environment do |_task, args|
    old_slug = args[:old_slug]
    new_slug = args[:new_slug]

    organisation = Organisation.find_by!(slug: old_slug)
    DataHygiene::OrganisationReslugger.new(organisation, new_slug).run!
  end
end
