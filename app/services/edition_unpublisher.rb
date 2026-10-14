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
                        elsif edition.try(:allows_child_documents?) && edition.child_editions.where(state: "draft").present?
                          "There are draft editions of child documents associated with this edition of this document. You must discard the draft editions of those child documents before unpublishing the parent edition."
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
  end

  def prepare_edition
    edition.force_published = false
    edition.reset_version_numbers
  end
end
