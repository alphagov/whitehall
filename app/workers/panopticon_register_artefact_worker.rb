require 'plek'
require 'gds_api/panopticon'

class PanopticonRegisterArtefactWorker < WorkerBase
  sidekiq_options queue: :panopticon

  def perform(edition_id, options = {})
    edition = Edition.find(edition_id)

    if edition.present?
      Whitehall.register_edition_with_panopticon(edition)
    end
  end
end
