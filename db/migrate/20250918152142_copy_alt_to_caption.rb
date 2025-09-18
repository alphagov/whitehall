class CopyAltToCaption < ActiveRecord::Migration[8.0]
  disable_ddl_transaction! # in case table is large, safer to batch in smaller updates

  def up
    say_with_time "Copying alt_text into caption where caption is empty" do
      Image.where(caption: [nil, ""])
           .where.not(alt_text: [nil, ""])
           .find_in_batches(batch_size: 1000) do |batch|
        Image.where(id: batch.map(&:id)).update_all("caption = alt_text")
      end
    end
  end

  def down
    # No-op: we can’t reliably undo since we don’t know which captions were originally blank.
  end
end
