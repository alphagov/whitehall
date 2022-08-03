class Licence < ApplicationRecord
  serialize :sectors, Array
  serialize :activities, Array
end
