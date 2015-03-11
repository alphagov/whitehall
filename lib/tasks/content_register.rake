require 'gds_api/content_register'

namespace :content_register do
  desc "registers all organisations with the content register"
  task :organisations=> :environment do
    content_register = GdsApi::ContentRegister.new(Plek.find('content-register'))
    Organisation.find_each do |organisation|
      content_register.put_entry(organisation.content_id, entry_for(organisation))
    end
  end

  def entry_for(organisation)
    {
      base_path: Whitehall.url_maker.organisation_path(organisation),
      format: 'organisation',
      title: organisation.name,
    }
  end
end
