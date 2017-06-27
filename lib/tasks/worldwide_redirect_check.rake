namespace :worldwide_redirect_check do
  desc "Check redirects for worldwide redirects from /government/world to /world"
  task check_all: :environment do
    Rake::Task["worldwide_redirect_check:check_world_root"].invoke

    Rake::Task["worldwide_redirect_check:check_embassies_root"].invoke

    Rake::Task["worldwide_redirect_check:check_world_locations"].invoke
    Rake::Task["worldwide_redirect_check:check_non_english_world_locations"].invoke
    Rake::Task["worldwide_redirect_check:check_world_location_news"].invoke
    Rake::Task["worldwide_redirect_check:check_non_english_world_location_news"].invoke

    Rake::Task["worldwide_redirect_check:check_world_organisations_root"].invoke
    Rake::Task["worldwide_redirect_check:check_world_organisations"].invoke
    Rake::Task["worldwide_redirect_check:check_non_english_world_organisations"].invoke
    Rake::Task["worldwide_redirect_check:check_world_organisation_corporate_information_pages"].invoke
    Rake::Task["worldwide_redirect_check:check_non_english_world_organisation_corporate_information_pages"].invoke
  end

  # Only used for testing, not called in `check_all` rake task
  task check_test_redirect: :environment do
    test_redirects = [
      {
        url: "/government/world/organisations/uk-trade-investment-russia",
        redirect_url: "/government/world/organisations/department-for-international-trade-russia",
      }
    ]
    WorldwideRedirectChecker.new(test_redirects).call
  end

  task check_world_root: :environment do
    world_location_root_redirects = [
      {
        url: "/government/world",
        redirect_url: "/world",
      }
    ]
    WorldwideRedirectChecker.new(world_location_root_redirects).call
  end

  task check_embassies_root: :environment do
    worldwide_embassies_root_redirects = [
      {
        url: "/government/world/embassies",
        redirect_url: "/world/embassies",
      }
    ]
    WorldwideRedirectChecker.new(worldwide_embassies_root_redirects).call
  end

  task check_world_locations: :environment do
    # There are 238 WorldLocations
    world_location_redirects_for_en_locale = WorldLocation.all.map do |wl|
      {
        url: "/government/world/#{wl.slug}",
        redirect_url: "/world/#{wl.slug}",
      }
    end
    WorldwideRedirectChecker.new(world_location_redirects_for_en_locale).call
  end

  task check_non_english_world_locations: :environment do
    world_location_redirects_for_other_locales = []
    WorldLocation.all.each do |wl|
      if wl.respond_to?(:original_available_locales)
        translated_locales = wl.original_available_locales - [:en]
        translated_locales.each do |twl_locale|
          expectation = {
            url: "/government/world/#{wl.slug}.#{twl_locale.code}",
            redirect_url: "/world/#{wl.slug}",
          }
          world_location_redirects_for_other_locales.push(expectation)
        end
      end
    end
    WorldwideRedirectChecker.new(world_location_redirects_for_other_locales).call
  end

  task check_world_location_news: :environment do
    world_location_news_redirects_for_en_locale = WorldLocation.all.map do |wl|
      {
        url: "/government/world/#{wl.slug}/news",
        redirect_url: "/world/#{wl.slug}/news",
      }
    end
    WorldwideRedirectChecker.new(world_location_news_redirects_for_en_locale).call
  end

  task check_non_english_world_location_news: :environment do
    world_location_news_redirects_for_other_locales = []
    WorldLocation.all.each do |wl|
      wl.non_english_translated_locales.each do |twl|
        expectation = {
          url: "/government/world/#{wl.slug}/news.#{twl.code}",
          redirect_url: "/world/#{wl.slug}/news.#{twl.code}",
        }
        world_location_news_redirects_for_other_locales.push(expectation)
      end
    end
    WorldwideRedirectChecker.new(world_location_news_redirects_for_other_locales).call
  end

  task check_world_organisations_root: :environment do
    worldwide_organisations_root_redirect = [
      {
        url: "/government/world/organisations",
        redirect_url: "/world/organisations",
      }
    ]
    WorldwideRedirectChecker.new(worldwide_organisations_root_redirect).call
  end

  task check_world_organisations: :environment do
    # There are 444 WorldLocations
    world_location_redirects_for_en_locale = WorldwideOrganisation.all.map do |wo|
      {
        url: "/government/world/organisations/#{wo.slug}",
        redirect_url: "/world/organisations/#{wo.slug}",
      }
    end
    WorldwideRedirectChecker.new(world_location_redirects_for_en_locale).call
  end

  task check_non_english_world_organisations: :environment do
    world_organisations_for_other_locales = []
    WorldwideOrganisation.all.each do |wwo|
      wwo.non_english_translated_locales.each do |wwo_locale|
        expectation = {
          url: "/government/world/organisations/#{wwo.slug}.#{wwo_locale.code}",
          redirect_url: "/world/organisations/#{wwo.slug}.#{wwo_locale.code}",
        }
        world_organisations_for_other_locales.push(expectation)
      end
    end
    WorldwideRedirectChecker.new(world_organisations_for_other_locales).call
  end

  task check_world_organisation_corporate_information_pages: :environment do
    orgs_with_corporate_info_pages = WorldwideOrganisation.all.select { |wwo| wwo.corporate_information_pages.present? }
    orgs_with_published_corporate_info_pages = orgs_with_corporate_info_pages.select { |wwo| wwo.corporate_information_pages.published.present? }

    corporate_info_page_redirects = []
    orgs_with_published_corporate_info_pages.each do |wwo|
      corporate_info_pages = wwo.corporate_information_pages.published
      corporate_info_pages.each do |cip|
        expectation = {
          url: Whitehall.url_maker.public_document_path(cip),
          redirect_url: Whitehall.url_maker.public_document_path(cip).gsub('/government', ''),
        }
        corporate_info_page_redirects.push(expectation)
      end
    end
    WorldwideRedirectChecker.new(corporate_info_page_redirects).call
  end

  task check_non_english_world_organisation_corporate_information_pages: :environment do
    orgs_with_corporate_info_pages = WorldwideOrganisation.all.select { |wwo| wwo.corporate_information_pages.present? }
    orgs_with_published_corporate_info_pages = orgs_with_corporate_info_pages.select { |wwo| wwo.corporate_information_pages.published.present? }

    corporate_info_page_redirects = []
    orgs_with_published_corporate_info_pages.each do |wwo|
      corporate_info_pages = wwo.corporate_information_pages.published
      corporate_info_pages.each do |cip|
        cip.non_english_translated_locales.each do |cip_locale|
          expectation = {
            url: Whitehall.url_maker.public_document_path(cip, locale: cip_locale),
            redirect_url: Whitehall.url_maker.public_document_path(cip, locale: cip_locale).gsub('/government', ''),
          }
          corporate_info_page_redirects.push(expectation)
        end
      end
    end
    WorldwideRedirectChecker.new(corporate_info_page_redirects).call
  end
end
