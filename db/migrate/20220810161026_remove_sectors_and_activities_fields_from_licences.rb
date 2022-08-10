class RemoveSectorsAndActivitiesFieldsFromLicences < ActiveRecord::Migration[7.0]
  # rubocop:disable Rails/BulkChangeTable
  def change
    remove_column :licences, :sectors, :text
    remove_column :licences, :activities, :text
  end
  # rubocop:enable Rails/BulkChangeTable
end
