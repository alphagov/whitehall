class AddAllNationApplicabilityToEdition < ActiveRecord::Migration[5.1]
  def change
    add_column :editions, :all_nation_applicability, :boolean, default: true
  end
end
