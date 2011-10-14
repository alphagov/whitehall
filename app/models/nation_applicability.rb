class NationApplicability < ActiveRecord::Base
  belongs_to :nation
  belongs_to :document
end