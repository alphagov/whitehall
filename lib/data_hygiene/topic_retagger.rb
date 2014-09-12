class TopicRetagger
  attr_reader :source_topic_id, :destination_topic_id

  def initialize(source_topic_id, destination_topic_id)
    @source_topic_id = source_topic_id
    @destination_topic_id = destination_topic_id
  end

  def retag
    # Grab the list of published editions before we make any changes to the
    # tags.  We'll need to re-register these after the re-tagging is done.
    taggings, published_editions = get_taggings_and_editions(source_topic_id)

    log "Updating #{taggings.count} taggings of editions (#{published_editions.count} published) to change #{source_topic_id} to #{destination_topic_id}"

    update_taggings(taggings)
    register_editions(published_editions)
  end

private

  def update_taggings(taggings)
    taggings.reject { |tagging| tagging.edition.nil? }.each do |tagging|
      if tagging.edition.specialist_sector_tags.include? destination_topic_id
        remove_tagging(tagging)
      else
        change_tagging(tagging)
      end
    end
  end

  def get_taggings_and_editions(topic_id)
    taggings = SpecialistSector.where(tag: topic_id)

    published_editions = taggings.map { |tagging|
      tagging.edition.try(:document).try(:published_edition)
    }.compact.uniq

    [taggings, published_editions]
  end

  def register_editions(editions)
    editions.each do |edition|
      log "registering '#{edition.slug}'"
      edition.reload
      registerable_edition = RegisterableEdition.new(edition)
      registerer           = Whitehall.panopticon_registerer_for(registerable_edition)
      registerer.register(registerable_edition)

      ServiceListeners::SearchIndexer.new(edition).index!
    end
  end

  def remove_tagging(tagging)
    edition = tagging.edition
    log "removing tagging on '#{edition.slug}' edition #{edition.id}"
    tagging.destroy

    add_editorial_remark(edition,
      "Bulk retagging from topic '#{source_topic_id}' to '#{destination_topic_id}' resulted in duplicate tag - removed it"
    )
  end

  def change_tagging(tagging)
    edition = tagging.edition
    log "tagging '#{edition.slug}' edition #{edition.id}"
    tagging.tag = destination_topic_id
    tagging.save!

    add_editorial_remark(edition,
      "Bulk retagging from topic '#{source_topic_id}' to '#{destination_topic_id}' changed tag"
    )
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
    @gds_user ||= User.find_by_email("govuk-whitehall@digital.cabinet-office.gov.uk")
  end

  def log(message)
    puts message
  end
end
