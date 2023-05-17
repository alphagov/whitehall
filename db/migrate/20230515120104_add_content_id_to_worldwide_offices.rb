class AddContentIdToWorldwideOffices < ActiveRecord::Migration[7.0]
  def change
    add_column :worldwide_offices, :content_id, :string

    WorldwideOffice.all.each { |office| office.update!(content_id: SecureRandom.uuid) }
  end
end
