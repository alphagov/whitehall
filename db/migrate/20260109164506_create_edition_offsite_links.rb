class CreateEditionOffsiteLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :edition_offsite_links, &:timestamps

    add_reference :edition_offsite_links, :edition
    add_reference :edition_offsite_links, :offsite_link
  end
end
