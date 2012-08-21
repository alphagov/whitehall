class StripInlineAttachmentsFromPublicationsAndConsultations < ActiveRecord::Migration
  def strip_attachments(govspeak)
    govspeak.gsub(/!@[1-9][0-9]?[\r\n]*/, "")
  end

  def strip_trailing_newlines(govspeak)
    govspeak.gsub(/[\r\n]+\Z/, "")
  end

  def remove_inline_attachments_from(edition)
    edition.update_column(:body, strip_trailing_newlines(strip_attachments(edition.body)))
  end

  def up
    Publication.where("body like ?", "%!@%").each do |publication|
      remove_inline_attachments_from(publication)
    end
    Consultation.where("body like ?", "%!@%").each do |edition|
      remove_inline_attachments_from(edition)
    end
  end

  def down
  end
end
