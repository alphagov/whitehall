require "test_helper"

class NavigationSelectionTest < ActiveSupport::TestCase
  include ApplicationHelper
  include Rails.application.routes.url_helpers
  define_method :default_url_options do
    {host: "example.com"}
  end

  EXCLUDED_CONTROLLERS = %w(
    application
    attachments
    case_studies
    detailed_guides
    document_series
    documents
    email_signups
    healthcheck
    html_versions
    mainstream_categories
    people
    placeholder
    public_facing
    public_uploads
    uploads
  ).map do |f|
    File.expand_path(Rails.root + "app/controllers/#{f}_controller.rb")
  end

  def test_every_controller_selects_navigation_item
    Dir[Rails.root + "app/controllers/*_controller.rb"].reject { |controller| is_excluded?(controller) }.each do |controller|
      assert_controller_select_main_navigation_path(controller)
    end
  end

  private

  def is_excluded?(controller)
    EXCLUDED_CONTROLLERS.include?(controller)
  end

  def assert_controller_select_main_navigation_path(controller_file)
    controller = File.basename(controller_file).sub('_controller.rb', '')
    assert current_main_navigation_path(controller: controller),
                 "could not find navigation path for controller: #{controller_file}"
  end

end
