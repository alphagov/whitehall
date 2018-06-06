class PreviouslyPublishedValidator < ActiveModel::Validator
  def validate(record)
    if record.previously_published.nil?
      record.errors[:base] << "You must specify whether the document has been published before"
      record.has_previously_published_error = true
    elsif record.previously_published
      if record.first_published_at.blank?
        record.errors.add(:first_published_at, "can't be blank")
      elsif record.first_published_at > Time.zone.now
        record.errors.add(:first_published_at, "can't be set to a future date")
      end
    end
  end
end
