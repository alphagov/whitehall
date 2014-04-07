class StatisticsAnnouncementDateChange < StatisticsAnnouncementDate
  validates :change_note, presence: { if: :major_date_change?, message: 'required for this date change' }
  validate :change_note_only_present_for_major_changes

  attr_accessor :current_release_date

  after_create :update_announcement_in_search_index

private

  def major_date_change?
    reducing_precision? ||
    changing_an_exact_date? ||
    changing_outside_of_one_month_window? ||
    changing_outside_of_two_month_window?
  end

  def reducing_precision?
    precision > current_release_date.precision
  end

  def changing_an_exact_date?
    current_release_date.precision == PRECISION[:exact] &&
      current_release_date.release_date != release_date
  end

  def changing_outside_of_one_month_window?
    current_release_date.precision == PRECISION[:one_month] &&
      release_date >= (current_release_date.release_date + 1.month)
  end

  def changing_outside_of_two_month_window?
    current_release_date.precision == PRECISION[:two_month] &&
      release_date >= (current_release_date.release_date + 2.month)
  end

  def update_announcement_in_search_index
    statistics_announcement.update_in_search_index
  end

  def change_note_only_present_for_major_changes
    if change_note.present? && !major_date_change?
      errors[:change_note] << 'only required for significant changes to the release date'
    end
  end
end
