class SpeechType < ActiveRecord::Base
  validates :name, presence: true
end