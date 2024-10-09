class ContentBlockManager::ScheduledPublicationValidator < ActiveModel::Validator
  attr_reader :edition

  def validate(edition)
    if edition.state == "scheduled"
      if edition.scheduled_publication.blank?
        edition.errors.add("scheduled_publication", :blank, message: "date and time cannot be blank")
      elsif edition.scheduled_publication < Time.zone.now
        edition.errors.add("scheduled_publication", :future_date, message: "date and time must be in the future")
      end
    end
  end
end
