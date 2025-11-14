class RemoveAltTextFromImages < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :images, :alt_text, :string }
  end
end
