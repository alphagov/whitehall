class MakeAttachmentsInline < ActiveRecord::Migration
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
