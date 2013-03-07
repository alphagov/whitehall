class EditionWorldwidePriority < ActiveRecord::Base
  belongs_to :edition
  belongs_to :worldwide_priority
end
