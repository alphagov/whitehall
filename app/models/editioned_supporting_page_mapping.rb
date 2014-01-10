class EditionedSupportingPageMapping < ActiveRecord::Base
  belongs_to :new_supporting_page, class_name: 'SupportingPage'
end
