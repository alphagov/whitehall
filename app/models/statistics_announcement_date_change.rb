class StatisticsAnnouncementDateChange < StatisticsAnnouncementDate
  validates :change_note, presence: { if: :changing_a_confirmed_date?, message: "required for this date change" }
  before_save :ignore_change_note, unless: :changing_a_confirmed_date?

  attr_accessor :current_release_date

private

  def ignore_change_note
    self.change_note = nil
  end

  def changing_a_confirmed_date?
    current_release_date.confirmed?
  end
end
