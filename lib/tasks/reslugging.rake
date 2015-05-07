require 'gds_api/router'
require 'gds_api/publishing_api'

namespace :reslug do
  desc "Change a person slug (DANGER!).\n

  This rake task changes a person's slug in whitehall.

  It performs the following steps:
  - changes the person's slug
  - reindexes the person for search
  - republishes the person to Publishing API
  - publishes a redirect content item to Publishing API
  - reindexes all dependent documents in search"
  task :person, [:old_slug, :new_slug] => :environment do |_task, args|
    old_slug = args[:old_slug]
    new_slug = args[:new_slug]
    person = Person.find_by!(slug: old_slug)

    DataHygiene::PersonReslugger.new(person, new_slug).run!
  end
end
