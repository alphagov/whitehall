class EditionedSupportingPageMapping < ActiveRecord::Base
  # TODO: Figure out if we need to add protection in the controllers with strong params
  # attr_accessible :new_supporting_page_id, :old_supporting_page_id

  belongs_to :new_supporting_page, class_name: 'SupportingPage'
end
