class AccessAndOpeningTimesForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :body

  attribute :body

  validates :body, presence: true

  def save(model)
    return false if invalid?

    model.access_and_opening_times = body
    model.save!
  end

  def marked_for_destruction?
    false
  end
end
