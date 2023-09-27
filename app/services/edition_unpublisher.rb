class EditionUnpublisher < EditionService
  def initialize(edition, options = {})
    super
    @edition.build_unpublishing(options[:unpublishing]) if options[:unpublishing]
  end

  def failure_reason
    @failure_reason ||= if !can_transition?
                          "An edition that is #{edition.current_state} cannot be #{past_participle}"
                        elsif edition.unpublishing.blank?
                          "The reason for unpublishing must be present"
                        elsif !edition.unpublishing.valid?
                          edition.unpublishing.errors.full_messages.to_sentence
                        end
  end

  def verb
    "unpublish"
  end

private

  def fire_transition!
    edition.public_send(verb)
    edition.save!(validate: false)
    edition.document.features.each(&:end!)
    mark_attachments_as_present_at_unpublish
  end

  def prepare_edition
    edition.force_published = false
    edition.reset_version_numbers
  end

  def mark_attachments_as_present_at_unpublish
    Attachment.where(attachable: edition.attachables).find_each do |attachment|
      next unless attachment.attachment_data

      attachment.attachment_data.update!(present_at_unpublish: true)
    end
  end
end
