class RegisterableEditionBuilderForUnpublishedEditions
  def self.build
    set_to_register.map do |edition|
      RegisterableEdition.new(edition)
    end
  end

private

  def self.edition_ids
    Unpublishing.all.map(&:edition_id)
  end

  def self.document_ids
    Edition.unscoped.find(edition_ids).map(&:document_id)
  end

  def self.edition_set
    document_ids.map do |document_id|
      Edition.unscoped.where(document_id: document_id).order(:id).last
    end
  end

  def self.set_to_register
    edition_set.reject do |edition|
      edition.related_policies.empty? if edition.respond_to?(:related_policies)
    end
  end
end
