class MakeAttachmentsInline < ActiveRecord::Migration
  class Edition < ActiveRecord::Base
    has_many :edition_attachments, foreign_key: :edition_id
    has_many :attachments, through: :edition_attachments
  end

  class Publication < Edition; end
  class Consultation < Edition; end
  class ConsultationResponse < Edition; end
  class Consultation < Edition; end

  class SupportingPage < ActiveRecord::Base
    has_many :supporting_page_attachments, foreign_key: :supporting_page_id
    has_many :attachments, through: :supporting_page_attachments
  end

  def add_attachments_to_body(record)
    new_body = record.body + "\n\n" + (1..record.attachments.length).map do |index|
      "!@#{index}"
    end.join("\n")
    record.update_attribute :body, new_body
  end
  def up
    [Publication, Consultation, ConsultationResponse, SpecialistGuide].each do |type|
      type.joins(:attachments).includes(:attachments).each do |record|
        add_attachments_to_body(record)
      end
    end
    # supporting pages may have a single deleted editon, so we need to
    # guard that case.
    SupportingPage.joins(:attachments).includes(:attachments).each do |record|
      if record.edition
        add_attachments_to_body(record)
      end
    end
  end

  def down
  end
end
