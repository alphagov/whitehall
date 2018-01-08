require "test_helper"

class NavigationSelectionTest < ActiveSupport::TestCase
  include ApplicationHelper
  include Rails.application.routes.url_helpers
  Rails.application.routes.default_url_options[:host] = "example.com"

  TESTED_CONTROLLERS = %w(
    announcements
    consultations
    corporate_information_pages
    email_signup_information
    histories
    home
    latest
    ministerial_roles
    news_articles
    operational_fields
    organisations
    past_foreign_secretaries
    policy_groups
    publications
    speeches
    statistical_data_sets
    statistics
    statistics
    world_location_news_articles
    world_locations
    worldwide_offices
    worldwide_organisations
  ).map do |f|
    File.expand_path(Rails.root + "app/controllers/#{f}_controller.rb")
  end

  def test_every_controller_selects_navigation_item
    TESTED_CONTROLLERS.each do |controller|
      assert_controller_select_main_navigation_path(controller)
    end
  end

private

  def tested_controllers
    Dir[Rails.root + "app/controllers/*_controller.rb"].reject do |controller|
      is_excluded?(controller)
    end
  end

  def assert_controller_select_main_navigation_path(controller_file)
    controller = File.basename(controller_file).sub('_controller.rb', '')
    assert current_main_navigation_path(controller: controller),
        "could not find navigation path for controller: #{controller_file}"
  end
end
