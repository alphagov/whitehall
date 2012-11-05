class CorporateInformationPageAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :corporate_information_page
end
