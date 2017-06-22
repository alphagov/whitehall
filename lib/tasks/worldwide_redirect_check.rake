# require 'lib/worldwide_redirect_checker'

desc "Check redirects for worldwide redirects from /government/world to /world"
task worldwide_redirect_check: :environment do
  # WORLD_LOCATIONS

  # test_redirects = [
  #   {
  #     url: "/government/world/organisations/uk-trade-investment-russia",
  #     redirect_url: "/government/world/organisations/department-for-international-trade-russia",
  #   }
  # ]

  world_location_root_redirects = [
    {
      url: "/government/world",
      redirect_url: "/world",
    }
  ]

  world_location_redirects_for_en = WorldLocation.all.map do |wl|
    {
      url: "/government/world/#{wl.slug}",
      redirect_url: "/world/#{wl.slug}",
    }
  end

  world_location_redirects_for_other_locales = [
    # TODO, will need to fetch the translations somehow
  ]

  world_location_news_redirects_for_en_locale = WorldLocation.all.map do |wl|
    {
      url: "/government/world/#{wl.slug}/news",
      redirect_url: "/world/#{wl.slug}/news",
    }
  end

  world_location_news_redirects_for_other_locales = [
    # TODO, will need to fetch the translations somehow
  ]


  # WORLDWIDE_ORGANISATIONS

  worldwide_organisations_root_redirect = [
    {
      url: "/government/world/organisations",
      redirect_url: "/world/organisations",
    }
  ]
  worldwide_organisations_redirects = [
    # TODO
  ]
  worldwide_organisation_corporate_information_pages_redirects = [
    # TODO
  ]
  worldwide_organisation_about_redirects = [
    # TODO
  ]
  worldwide_organisation_offices_redirects = [
    # TODO
  ]


  # EMBASSIES FINDER PAGE

  worldwide_embassies_root_redirects = [
    {
      url: "/government/world/embassies",
      redirect_url: "/world/embassies",
    }
  ]

  redirects = [
    # test_redirects,
    world_location_root_redirects,
    world_location_redirects_for_en,
    world_location_redirects_for_other_locales,
    world_location_news_redirects_for_en_locale,
    world_location_news_redirects_for_other_locales,
    worldwide_organisations_root_redirect,
    worldwide_organisations_redirects,
    worldwide_organisation_corporate_information_pages_redirects,
    worldwide_organisation_about_redirects,
    worldwide_organisation_offices_redirects,
    worldwide_embassies_root_redirects,
  ]

  redirects.each do |r_list|
    WorldwideRedirectChecker.new(r_list).call
  end
end
