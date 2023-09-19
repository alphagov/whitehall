class ChangeNoteForm
  include ActiveModel::Model

  attr_accessor :minor_change, :change_note

  validates :minor_change, inclusion: { in: [true, false] }
  validates :change_note, presence: true, if: :major_version?

  def self.build_from_edition(edition)
    new(
      minor_change: edition.minor_change,
      change_note: edition.change_note,
    )
  end

  def save!(edition)
    self.minor_change = ActiveModel::Type::Boolean.new.cast(minor_change)

    return false unless valid?

    if major_version?
      edition.update!(
        change_note:,
        minor_change:,
      )
    else
      edition.update!(
        change_note: nil,
        minor_change:,
      )
    end
  end

private

  def major_version?
    minor_change == false
  end
end
