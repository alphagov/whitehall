class FatalityNotice < Announcement
  belongs_to :operational_field

  validates :operational_field, presence: true
end
