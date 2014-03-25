desc "Generate organisation thumbnails. Set ORGANISATION to the slug of a specific organisation; Set ORGANISATION_FILE to a file of slugs; Set OVERWRITE to replace existing screenshots"
task :organisation_screenshots => :environment do
  FileUtils.mkdir_p(screenshot_root)

  organisations = if ENV["ORGANISATION"]
    Organisation.where(slug: ENV["ORGANISATION"])
  elsif ENV["ORGANISATION_FILE"] and File.exist? ENV["ORGANISATION_FILE"]
    slugs = File.open(ENV["ORGANISATION_FILE"]).readlines.map(&:chomp)
    Organisation.where(slug: slugs)
  else
    Organisation.where(govuk_status: %w(joining exempt transitioning)).where("url <> ''")
  end

  organisations.each.with_index do |org, i|
    puts "(#{i+1}/#{organisations.length}) Processing #{org.name} - #{org.url}"

    tmp_screenshot_path = File.join(Rails.root + "tmp", "#{org.slug}.png")
    screenshot_path = screenshot_path_for(org)

    next if File.exist?(screenshot_path) unless ENV["OVERWRITE"] || ENV["ORGANISATION"]

    `phantomjs lib/screenshot.js "#{org.url}" 1024 768 "#{tmp_screenshot_path}"`
    if File.exist?(tmp_screenshot_path)
      compose_screenshot(screenshot_path, tmp_screenshot_path)
    else
      puts "Failed to save screenshot for #{org.name}"
    end
  end
end

def screenshot_root
  Rails.root + "app/assets/images/organisation_screenshots"
end

def screenshot_path_for(organisation)
  File.join(screenshot_root, organisation.slug + ".png")
end

def compose_screenshot(screenshot_path, tmp_screenshot_path)
  chrome_path = File.join(Rails.root + "app/assets/images", "browser_bar_small.png")

  `mogrify -crop 1024x768+0+0 -thumbnail 287 "#{tmp_screenshot_path}"`
  `convert -size 287x215 xc:white "#{chrome_path}" -geometry +0+0 -composite "#{tmp_screenshot_path}" -geometry +0+18 -composite "#{screenshot_path}"`
  FileUtils.rm(tmp_screenshot_path)
end

namespace :organisation_screenshots do
  task :manual, [:org_slug, :path_to_screenshot] => :environment do |t, args|
    organisation = Organisation.where(slug: args[:org_slug]).first

    compose_screenshot(screenshot_path_for(organisation), args[:path_to_screenshot])
  end

  task :clean => :environment do
    all_slugs = Organisation.all.map(&:slug)

    Dir[File.join(screenshot_root, "*")].each do |file|
      unless all_slugs.include?(File.basename(file, ".png"))
        FileUtils.rm(file)
      end
    end
  end
end
