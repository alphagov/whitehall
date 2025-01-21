class ContentBlockManager::ScheduledPublicationValidator < ActiveModel::Validator
  attr_reader :edition

  def validate(edition)
    if edition.scheduled_publication.blank?
      edition.errors.add("scheduled_publication", :blank)
    elsif edition.scheduled_publication < Time.zone.now
      edition.errors.add("scheduled_publication", :future_date)
    end
  end
end
