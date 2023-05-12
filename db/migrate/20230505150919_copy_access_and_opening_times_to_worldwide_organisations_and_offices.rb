class CopyAccessAndOpeningTimesToWorldwideOrganisationsAndOffices < ActiveRecord::Migration[7.0]
  def change
    AccessAndOpeningTimes.all.each do |access|
      model = access.accessible_type.constantize
      accessible = model.find(access.accessible_id)

      accessible.update_columns(access_and_opening_times: access.body)
    end
  end

  class AccessAndOpeningTimes < ApplicationRecord
    belongs_to :accessible, polymorphic: true
  end
end
