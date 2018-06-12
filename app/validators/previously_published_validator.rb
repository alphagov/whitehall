class PreviouslyPublishedValidator < ActiveModel::Validator
  def validate(record)
    record.has_previously_published_error = false

    if record.previously_published.nil?
      record.errors[:base] << "You must specify whether the document has been published before"
      record.has_previously_published_error = true
    elsif record.previously_published && record.first_published_at.blank?
      record.errors.add(:first_published_at, "can't be blank")
    end

    if record.first_published_at && Time.zone.now < record.first_published_at
      record.errors.add(:first_published_at, "can't be set to a future date")
    end
  end
end
