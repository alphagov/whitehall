class EditionedSupportingPageMapping < ActiveRecord::Base
  attr_accessible :new_supporting_page_id, :old_supporting_page_id

  belongs_to :new_supporting_page, class_name: 'SupportingPage'
end
