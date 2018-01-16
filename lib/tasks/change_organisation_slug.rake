desc "Change an organisation slug (DANGER!).\n

This rake task changes an organisation slug in whitehall.

It performs the following steps:
- changes org slug
- changes organisation_slug of users
- re-registers org with search
- re-registers any related editions with search

It is one part of an inter-related set of steps which must be carefully
coordinated.

For reference:

https://github.com/alphagov/wiki/wiki/Changing-GOV.UK-URLs#changing-an-organisations-slug"

task :change_organisation_slug, %i[old_slug new_slug] => :environment do |_task, args|
  logger = Logger.new(STDOUT)
  organisation = Organisation.find_by(slug: args[:old_slug])
  if organisation
    Whitehall::OrganisationSlugChanger.new(organisation, args[:new_slug], logger: logger).call
  else
    logger.error("Organisation with slug '#{args[:old_slug]}' not found")
  end
end
