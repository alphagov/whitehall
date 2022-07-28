class UpdateLiveAndLatestEditionId
  attr_accessor :edition, :document

  def initialize(edition)
    @edition = edition
    @document = edition.document
  end

  def call
    update_live_edition_id
    update_latest_edition_id
  end

private

  def update_live_edition_id
    document.update!(live_edition_id: edition.id) if edition.state.in?(Edition::PUBLICLY_VISIBLE_STATES)
  end

  def update_latest_edition_id
    document.update!(latest_edition_id: edition.id) if !edition.deleted? && (latest_edition_id_is_blank? || edition_is_most_recent_pre_publication_edition?)
  end

  def latest_edition_id_is_blank?
    document.latest_edition_id.blank?
  end

  def edition_is_most_recent_pre_publication_edition?
    edition.id == document.editions.where(state: [Edition::PRE_PUBLICATION_STATES]).order(id: :desc).first&.id
  end
end
