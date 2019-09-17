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

  def change_note_only_present_for_major_changes
    if change_note.present? && !major_date_change?
      errors[:change_note] << "only required for significant changes to the release date"
    end
  end
end
