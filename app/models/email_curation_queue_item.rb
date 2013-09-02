# == Schema Information
#
# Table name: email_curation_queue_items
#
#  id                :integer          not null, primary key
#  edition_id        :integer          not null
#  title             :string(255)
#  summary           :text
#  notification_date :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

class EmailCurationQueueItem < ActiveRecord::Base
  belongs_to :edition

  validates :edition, :title, :summary, :notification_date, presence: true

  def self.create_from_edition(edition, notification_date)
    create(edition: edition, title: edition.title, summary: edition.summary, notification_date: notification_date)
  end
end
