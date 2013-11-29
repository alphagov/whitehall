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
    superseded_editions.each do |superseded_edition|
      logger.info "checking #{superseded_edition.id} against: #{superseded_editions.collect(&:id)}"

      if duplicate = find_duplicate(superseded_edition)
        logger.info "  #{superseded_edition.id} is a duplicate of #{duplicate.id}"
        delete(superseded_edition)
      end
    end
  end

private

  def superseded_editions
    document.editions.includes(:translations).superseded.in_reverse_chronological_order
  end

  def ever_published_editions
    document.ever_published_editions
  end

  def find_duplicate(superseded_edition)
    ever_published_editions.includes(:translations).detect { |edition| duplicates?(edition, superseded_edition) }
  end

  def duplicates?(edition1, edition2)
    edition1 != edition2 && edition1.body == edition2.body && edition1.title == edition2.title
  end

  def delete(edition)
    logger.info  "  Destroying supporting page #{edition.id}"
    edition.destroy
    logger.info  "  Destroying supporting page attachments: #{edition.attachments.collect(&:id)}"
    edition.attachments.destroy_all
  end
end
