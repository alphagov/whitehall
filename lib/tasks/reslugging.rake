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
    document = Document.find_by(slug: args.old_slug)
    # remove the most recent edition from the search index
    edition = document.editions.published.last
    Whitehall::SearchIndex.delete(edition)

    # change the slug of the document and create a redirect from the original
    document.update_attributes!(slug: args.new_slug)
    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  end
end
