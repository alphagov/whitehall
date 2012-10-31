class RegenerateImageSizes < ActiveRecord::Migration
  def up
    ImageData.all.each do |image_data|
      begin
        image_data.file.recreate_versions!
      rescue => e
        $stderr.puts "ERROR recreating image data for #{image_data.id} -> #{e.to_s}"
        raise e unless Rails.env.development? || ENV["FACTER_govuk_platform"] == "preview"
      end
    end
  end

  def down
    # intentionally left blank
  end
end
