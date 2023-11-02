class RemoveTopicalEventLogoField < ActiveRecord::Migration[7.0]
  def change
    remove_column :topical_events, :carrierwave_image, :string
  end
end
