unless Rails.env.production?
  require 'teaspoon/suite_controller'

  class Teaspoon::SuiteController
    before_action -> {
      response.headers[Slimmer::Headers::SKIP_HEADER] = "true"
    }
  end
end
