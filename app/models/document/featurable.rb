module Document::Featurable
  extend ActiveSupport::Concern

  def featurable?
    published?
  end

  def featured?
    featuring_id.present?
  end

  def feature
    create_featuring!
    save!
  end

  def unfeature
    featuring.destroy
    update_attributes!(featuring: nil)
  end

  included do
    belongs_to :featuring
  end

  module ClassMethods
    def featured
      where "featuring_id IS NOT NULL"
    end

    def not_featured
      where "featuring_id IS NULL"
    end
  end
end