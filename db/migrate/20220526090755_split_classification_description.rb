class SplitClassificationDescription < ActiveRecord::Migration[7.0]
  def up
    Classification.find_each do |classification|
      split_description = classification.description.split(/[\r\n]+/)

      summary = split_description[0] if split_description&.any?
      description = split_description[1..split_description.length].join("\r\n\r\n") if split_description.length > 1

      classification.update_columns(
        summary:,
        description:,
      )
    end
  end
end
