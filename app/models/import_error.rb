# == Schema Information
#
# Table name: import_errors
#
#  id         :integer          not null, primary key
#  import_id  :integer
#  row_number :integer
#  message    :text
#  created_at :datetime
#

class ImportError < ActiveRecord::Base
end
