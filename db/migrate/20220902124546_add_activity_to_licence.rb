class AddActivityToLicence < ActiveRecord::Migration[7.0]
  def change
    add_reference :licences, :activity, index: true
  end
end
