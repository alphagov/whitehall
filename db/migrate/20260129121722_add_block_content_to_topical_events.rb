class AddBlockContentToTopicalEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :topical_events, :block_content, :json
  end
end
