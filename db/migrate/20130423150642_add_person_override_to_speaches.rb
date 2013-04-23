class AddPersonOverrideToSpeaches < ActiveRecord::Migration
  def change
    add_column :editions, :person_override, :string
  end
end
