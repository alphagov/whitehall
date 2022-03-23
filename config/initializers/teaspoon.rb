Whitehall::Application.config.to_prepare do
  unless Rails.env.production?
    require "teaspoon/suite_controller"

    class Teaspoon::SuiteController
      before_action lambda {
        response.headers[Slimmer::Headers::SKIP_HEADER] = "true"
      }
    end
  end
end
