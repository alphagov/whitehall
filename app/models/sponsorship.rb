class Sponsorship < ApplicationRecord
  belongs_to :organisation
  belongs_to :worldwide_organisation
end
