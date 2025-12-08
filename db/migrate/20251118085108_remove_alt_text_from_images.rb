class RemoveAltTextFromImages < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :images, :alt_text, :string
    end
  end
end
