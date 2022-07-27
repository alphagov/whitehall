class UpdateLiveAndLatestEditionId
  attr_accessor :document

  def initialize(document)
    @document = document
  end

  def call
    update_live_edition_id
    update_latest_edition_id
  end

private

  def update_live_edition_id
    live_edition_id = document.editions.where(state: Edition::PUBLICLY_VISIBLE_STATES).order(id: :desc).limit(1).first&.id
    document.update!(live_edition_id: live_edition_id)
  end

  def update_latest_edition_id
    latest_edition_id = document.editions.where.not(state: "deleted").order(id: :desc).limit(1).first&.id
    document.update!(latest_edition_id: latest_edition_id)
  end
end
