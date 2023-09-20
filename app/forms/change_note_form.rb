class ChangeNoteForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :minor_change, :boolean, default: false
  attribute :change_note

  validates :minor_change, inclusion: { in: [true, false] }
  validates :change_note, presence: true, if: :major_version?

  def self.build_from_edition(edition)
    new(
      minor_change: edition.minor_change,
      change_note: edition.change_note,
    )
  end

  def save!(edition)
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
