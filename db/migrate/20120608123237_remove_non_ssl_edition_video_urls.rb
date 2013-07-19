class RemoveNonSslEditionVideoUrls < ActiveRecord::Migration

  class EditionTable < ActiveRecord::Base
    self.table_name = "editions"
  end

  def change
    EditionTable.where("video_url LIKE 'http:%'").each do |edition|
      edition.update_column(:video_url, nil)
    end
  end
end
