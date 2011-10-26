class AddAlternativeUrlToNationInapplicabilities < ActiveRecord::Migration
  def change
    add_column :nation_inapplicabilities, :alternative_url, :string
  end
end
