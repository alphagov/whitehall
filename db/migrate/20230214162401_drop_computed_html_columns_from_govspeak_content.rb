class DropComputedHtmlColumnsFromGovspeakContent < ActiveRecord::Migration[7.0]
  def change
    change_table :govspeak_contents, bulk: true do |t|
      t.remove :computed_body_html, :computed_headers_html, type: :text
    end
  end
end
