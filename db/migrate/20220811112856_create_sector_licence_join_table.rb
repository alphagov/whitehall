class CreateSectorLicenceJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :sectors, :licences
  end
end
