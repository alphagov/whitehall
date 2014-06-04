class Sponsorship < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :worldwide_organisation
end
