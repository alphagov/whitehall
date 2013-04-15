class EmailCurationQueueItem < ActiveRecord::Base
  belongs_to :edition

  validates :edition, :title, :summary, :notification_date, presence: true
end