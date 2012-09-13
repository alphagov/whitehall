desc "Generate organisation thumbnails. Set ORGANISATION to the slug of a specific organisation; Set OVERWRITE to replace existing screenshots"
task :organisation_screenshots => :environment do
  screenshot_root = Rails.root + "app/assets/images/organisation_screenshots"
  chrome_path = File.join(Rails.root + "app/assets/images", "browser_bar_small.png")

  FileUtils.mkdir_p(screenshot_root)

  organisations = if ENV["ORGANISATION"]
    Organisation.where(slug: ENV["ORGANISATION"])
  else
    Organisation.where("govuk_status <> 'live'").where("url <> ''")
  end

  organisations.each.with_index do |org, i|
    puts "(#{i+1}/#{organisations.length}) Processing #{org.name} - #{org.url}"

    screenshot_path = File.join(screenshot_root, org.slug + ".png")
    tmp_screenshot_path = File.join(Rails.root + "tmp", "#{org.slug}.png")

    next if File.exist?(screenshot_path) unless ENV["OVERWRITE"] || ENV["ORGANISATION"]

    `phantomjs lib/screenshot.js "#{org.url}" 1024 768 "#{tmp_screenshot_path}"`
    if File.exist?(tmp_screenshot_path)
      `mogrify -crop 1024x768+0+0 -thumbnail 287 "#{tmp_screenshot_path}"`
      `convert -size 287x215 xc:white "#{chrome_path}" -geometry +0+0 -composite "#{tmp_screenshot_path}" -geometry +0+18 -composite "#{screenshot_path}"`
      FileUtils.rm(tmp_screenshot_path)
    else
      puts "Failed to save screenshot for #{org.name}"
    end
  end
end
