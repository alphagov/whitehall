# Enqueues CheckAllEditionsLinksWorker for all organisations
require "sidekiq-scheduler"

class CheckAllOrganisationsLinksWorker
  include Sidekiq::Worker

  def perform
    organisations.each do |organisation|
      CheckOrganisationLinksWorker.perform_async(organisation.id)
    end
  end

private

  def organisations
    Organisation.all
  end
end
