require 'test_helper'

class ServiceListeners::AuthorNotifierTest < ActiveSupport::TestCase
  setup { ActionMailer::Base.deliveries.clear }

  test 'notifies users' do
    edition = create(:edition)
    creator = edition.creator
    second_author = create(:gds_editor)
    edition.authors << second_author

    ServiceListeners::AuthorNotifier.new(edition).notify!

    first_notification = ActionMailer::Base.deliveries.first
    assert_equal creator.email, first_notification.to[0]
    assert_match(/\'#{edition.title}\' has been published/, first_notification.subject)

    second_notification = ActionMailer::Base.deliveries.last
    assert_equal second_author.email, second_notification.to[0]
    assert_match(/\'#{edition.title}\' has been published/, second_notification.subject)
  end

  test 'skips any users that are passed in' do
    edition = create(:edition)
    creator = edition.creator
    second_author = create(:gds_editor)
    edition.authors << second_author

    ServiceListeners::AuthorNotifier.new(edition, second_author).notify!

    assert_equal 1, ActionMailer::Base.deliveries.size

    first_notification = ActionMailer::Base.deliveries.first
    assert_equal creator.email, first_notification.to[0]
    assert_match(/\'#{edition.title}\' has been published/, first_notification.subject)
  end

  def notify(environment: nil)
    GovukAdminTemplate.environment_style = environment
    GovukAdminTemplate.environment_label = environment.try(:titleize)

    edition = create(:edition)
    ServiceListeners::AuthorNotifier.new(edition).notify!

    GovukAdminTemplate.environment_style = nil
    GovukAdminTemplate.environment_label = nil
  end

  test 'sets a suitable "from" including a quoted display name' do
    notify
    notify(environment: "integration")
    notify(environment: "production")

    assert_equal 3, ActionMailer::Base.deliveries.size

    first_notification = ActionMailer::Base.deliveries.first
    # GovukAdminTemplate.environment_label isn't set in tests, hence the space inside the brackets
    assert_equal '"[GOV.UK ] GOV.UK publishing" <inside-government+@digital.cabinet-office.gov.uk>', first_notification[:from].to_s

    integration_notification = ActionMailer::Base.deliveries.second
    assert_equal '"[GOV.UK Integration] GOV.UK publishing" <inside-government+integration@digital.cabinet-office.gov.uk>', integration_notification[:from].to_s

    production_notification = ActionMailer::Base.deliveries.third
    assert_equal '"GOV.UK publishing" <inside-government@digital.cabinet-office.gov.uk>', production_notification[:from].to_s
  end

  test 'sets a suitable footer' do
    notify
    notify(environment: "integration")
    notify(environment: "production")

    assert_equal 3, ActionMailer::Base.deliveries.size

    pattern = /this email has been sent from a GOV\.UK testing environment/

    first_notification = ActionMailer::Base.deliveries.first
    assert_match pattern, first_notification.to_s

    integration_notification = ActionMailer::Base.deliveries.second
    assert_match pattern, integration_notification.to_s

    production_notification = ActionMailer::Base.deliveries.third
    refute_match pattern, production_notification.to_s
  end
end
