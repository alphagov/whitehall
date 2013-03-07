class AddWorldwideOfficeTypeToWorldwideOffice < ActiveRecord::Migration
  def change
    # add colum...
    add_column :worldwide_offices, :worldwide_office_type_id, :integer
    # ...then make it non-nullable by applying a default of 99 to existing
    # rows, but leaving it without a SQL default
    change_column_null :worldwide_offices, :worldwide_office_type_id, false, 999
  end
end
