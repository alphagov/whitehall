require 'supporting_page'

class SupportingPage
  has_one :editioned_supporting_page_mapping, foreign_key: :new_supporting_page_id
end

class OldSupportingPage < ActiveRecord::Base
  self.table_name = 'supporting_pages'

  belongs_to :edition
end


class SupportingPageCleaner
  attr_accessor :document, :logger

  def initialize(document, logger=Logger.new(nil))
    @document = document
    @logger   = logger
  end

  # Will delete any superseded editions where another exists with the same body
  # text and title.  Also checks against published editions, meaning that any
  # superseded editions that are duplicates of the published edition will also
  # be deleted.
  def delete_duplicate_superseded_editions!
    logger.info "Deleting duplicate migrated editions of #{document.slug}"
    superseded_editions.each do |superseded_edition|
      logger.info "Checking #{superseded_edition.id} against: #{superseded_editions.collect(&:id)}"

      if duplicates_exists?(superseded_edition)
        check_off_from_content_digests(superseded_edition)
        logger.info "  #{superseded_edition.id} is a duplicate of another edition"
        delete(superseded_edition)
      end
    end
  end

  def repair_version_history!
    logger.info "Repairing version history for editions of #{document.slug}"
    fix_versions_and_change_notes_for_migrated_editions!
    renumber_subsequent_editions!
    logger.info "Repairing publishing timestamps for editions of #{document.slug}"
    repair_edition_timestamps!
  end

  def fix_versions_and_change_notes_for_migrated_editions!
    migrated_editions.reverse.each do |edition|
      edition.change_note = nil
      if migrated_editions.last == edition
        logger.info "  #{edition.id} is a is the first migrated edition - setting minor change to false"
        edition.minor_change = false
        edition.published_major_version = 1
        edition.published_minor_version = 0
      else
        logger.info "  #{edition.id} is a subsequent migrated edition - setting as minor change"
        edition.minor_change = true
        edition.reset_version_numbers
        edition.increment_version_number
      end

      edition.save(validate: false)
    end
  end

  def renumber_subsequent_editions!
    non_migrated_editions.each do |edition|
      edition.reset_version_numbers
      edition.increment_version_number
      logger.info "  #{edition.id} is editor-created; public_version recalculated as #{edition.published_version}"
      edition.save(validate: false)
    end
  end

  def repair_edition_timestamps!
    migrated_editions.each do |edition|
      logger.info "  #{edition.id} - setting first_published_timestamp and major_change_published_at to #{first_published_timestamp.to_s(:short)}"
      edition.first_published_at        = first_published_timestamp
      edition.major_change_published_at = first_published_timestamp
      edition.save(validate: false)
    end

    non_migrated_editions.each do |edition|
      logger.info "  #{edition.id} - setting first_published_timestamp to #{first_published_timestamp.to_s(:short)}"
      edition.first_published_at = first_published_timestamp
      edition.save(validate: false)
    end
  end

  def duplicates_exists?(edition)
    content_digests[content_digest(edition)] > 1
  end

private

  def migrated_editions
    ever_published_editions.in_reverse_chronological_order.select {|edition| edition.editioned_supporting_page_mapping }
  end

  def non_migrated_editions
    ever_published_editions.in_chronological_order.select {|edition| !edition.editioned_supporting_page_mapping }
  end

  def superseded_editions
    document.editions.includes(:translations, :editioned_supporting_page_mapping, :attachments).superseded.in_reverse_chronological_order
  end

  def ever_published_editions
    document.ever_published_editions.includes(:translations, :editioned_supporting_page_mapping, :attachments)
  end

  def first_published_timestamp
    @first_published_timestamp ||= original_policy.public_timestamp
  end

  def original_policy
    OldSupportingPage.find(migrated_editions.last.editioned_supporting_page_mapping.old_supporting_page_id).edition
  end

  def content_digests
    @content_digests ||= ever_published_editions.each_with_object(Hash.new(0)) { |edition, hash| hash[content_digest(edition)] +=1 }
  end

  def content_digest(edition)
    Digest::MD5.hexdigest [edition.title, edition.body, attachments_string(edition)].join
  end

  def attachments_string(edition)
    edition.attachments.inject('') do |string, att|
      string << att.attributes.except(*%w(id created_at updated_at attachable_id)).values.join
    end
  end

  def check_off_from_content_digests(edition)
    content_digests[content_digest(edition)] -= 1
  end

  def delete(edition)
    logger.info  "  Destroying supporting page #{edition.id}"
    edition.destroy
    logger.info  "  Destroying supporting page attachments: #{edition.attachments.collect(&:id)}"
    edition.attachments.destroy_all
  end
end
