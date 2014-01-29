require 'plek'
require 'gds_api/panopticon'

class PanopticonRegisterArtefactWorker
  include Sidekiq::Worker
  sidekiq_options queue: :panopticon

  def perform(edition_id, options={})
    edition = Edition.find(edition_id)

    if edition.present?
      registerable_edition = RegisterableEdition.new(edition)

      registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: 'whitehall-frontend', kind: registerable_edition.kind)
      registerer.register(registerable_edition)
    end
  end
end
