# Enqueues CheckAllEditionsLinksWorker for all organisations
require "sidekiq-scheduler"

class CheckAllOrganisationsLinksWorker
  include Sidekiq::Worker

  def perform
    organisations.each_with_index do |organisation, index|
      offset = (index * 60).seconds
      CheckOrganisationLinksWorker.perform_in(offset, organisation.id)
    end
  end

private

  def organisations
    Organisation.all
  end
end
