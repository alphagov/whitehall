desc "Move content from one topic to another"
task :move_content_to_new_topic => :environment do
  source_topic_id = ENV['source']
  dest_topic_id = ENV['dest']

  if source_topic_id == dest_topic_id
    puts "Source and destination topics are the same"
    exit
  end

  TopicRetagger.new(source_topic_id, dest_topic_id).retag
end

class TopicRetagger
  attr_reader :source_topic_id, :dest_topic_id

  def initialize(source_topic_id, dest_topic_id)
    @source_topic_id = source_topic_id
    @dest_topic_id = dest_topic_id
  end

  def retag
    taggings = SpecialistSector.where(tag: source_topic_id)

    # Grab the list of published editions before we make any changes to the
    # tags.  We'll need to re-register these after the re-tagging is done.
    published_editions = calc_published_editions(taggings)

    log "Updating #{taggings.count} taggings of editions (#{published_editions.count} published) to change #{source_topic_id} to #{dest_topic_id}"

    update_taggings(taggings)

    register_editions(published_editions)
  end

private

  def update_taggings(taggings)
    taggings.reject { |tagging| tagging.edition.nil? }.each do |tagging|
      if tagging.edition.specialist_sector_tags.include? dest_topic_id
        remove_tagging(tagging)
      else
        change_tagging(tagging)
      end
    end
  end

  def calc_published_editions(taggings)
    taggings.map { |tagging|
      edition = tagging.edition
      if edition
        document = edition.document
        if document
          document.published_edition
        end
      end
    }.compact.uniq
  end

  def register_editions(editions)
    editions.each do |edition|
      log "registering '#{edition.slug}'"
      registerable_edition = RegisterableEdition.new(edition)
      registerer           = Whitehall.panopticon_registerer_for(registerable_edition)
      registerer.register(registerable_edition)
    end
  end

  def remove_tagging(tagging)
    edition = tagging.edition
    log "removing tagging on '#{edition.slug}' edition #{edition.id}"
    tagging.destroy

    add_editorial_remark(edition,
      "Bulk retagging from topic '#{source_topic_id}' to '#{dest_topic_id}' resulted in duplicate tag - removed it"
    )
  end

  def change_tagging(tagging)
    edition = tagging.edition
    log "tagging '#{edition.slug}' edition #{edition.id}"
    tagging.tag = dest_topic_id
    tagging.save!

    add_editorial_remark(edition,
      "Bulk retagging from topic '#{source_topic_id}' to '#{dest_topic_id}' changed tag"
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
