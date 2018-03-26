# DID YOU MEAN: Topic?
# "Policy area" is the newer name for "topic"
# (https://www.gov.uk/government/topics)
# "Topic" is the newer name for "specialist sector"
# (https://www.gov.uk/topic)
class SpecialistSector < ApplicationRecord
  belongs_to :edition

  validates :edition, presence: true
  validates :topic_content_id, presence: true, uniqueness: { scope: :edition_id }

  def edition
    Edition.unscoped { super }
  end

  def content_id
    topic_content_id
  end
end
