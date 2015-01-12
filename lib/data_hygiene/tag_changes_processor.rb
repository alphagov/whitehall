class TagChangesProcessor

  def initialize(csv_location)
    @csv_location = csv_location
  end

  def process
    tag_changes_list.each do |changes|
      @document_id = changes["document_id"]
      @source_topic_id = changes["remove_topic"]
      @destination_topic_id = changes["add_topic"]
      processor
    end
  end

private

  attr_reader :csv_location

  def tag_changes_list
    CSV::read(csv_location, headers: true)
  end

  def processor
    log "Updating #{taggings.count} taggings to change #{@source_topic_id} to #{@destination_topic_id}"
    update_taggings
    register_edition(latest_edition)
  end

  def update_taggings
    taggings.reject { |tagging| tagging.edition.nil? }.each do |tagging|
      if tagging.edition.specialist_sector_tags.include? @destination_topic_id
        remove_tagging(tagging)
      else
        change_tagging(tagging)
      end
    end
  end

  def remove_tagging(tagging)
    edition = tagging.edition
    log "removing tagging on '#{edition.slug}' edition #{edition.id}"
    tagging.destroy

    add_editorial_remark(edition,
      "Bulk retagging from topic '#{@source_topic_id}' to '#{@destination_topic_id}' resulted in duplicate tag - removed it"
    )
  end

  def change_tagging(tagging)
    edition = tagging.edition
    log "tagging '#{edition.slug}' edition #{edition.id}"
    tagging.tag = @destination_topic_id
    tagging.save!

    add_editorial_remark(edition,
      "Bulk retagging from topic '#{@source_topic_id}' to '#{@destination_topic_id}' changed tag"
    )
  end

  def latest_edition
    document.latest_edition
  end

  def document
    Document.find(@document_id)
  end

  def taggings
    document.editions.flat_map { |edition|
      edition.specialist_sectors.where(tag: @source_topic_id).compact.uniq
    }
  end

  def register_edition(edition)
    log "registering '#{edition.slug}'"
    edition.reload
    register_with_panopticon(edition)
    register_with_publishing_api(edition)
    register_with_search(edition)
  end

  def register_with_panopticon(edition)
    registerable_edition = RegisterableEdition.new(edition)
    registerer           = Whitehall.panopticon_registerer_for(registerable_edition)
    registerer.register(registerable_edition)
  end

  def register_with_publishing_api(edition)
    Whitehall::PublishingApi.republish(edition)
  end

  def register_with_search(edition)
    ServiceListeners::SearchIndexer.new(edition).index!
  end

  def add_editorial_remark(edition, message)
    if edition.nil?
      log " - no edition (probably deleted)"
    elsif Edition::FROZEN_STATES.include?(edition.state)
      log " - edition is frozen; skipping editorial remarks"
    else
      log " - adding editorial remark"
      edition.editorial_remarks.create!(
        author: gds_user,
        body: message
      )
    end
  end

  def gds_user
    @gds_user ||= User.find_by(email: "govuk-whitehall@digital.cabinet-office.gov.uk")
  end

  def log(message)
    puts message
  end
end
