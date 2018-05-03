require "test_helper"

class ConsultationReminderTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
    Timecop.freeze(2018, 5, 2, 1, 0, 0)
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end

  test ".send_all notifies authors of consultations with 4 weeks left without an outcome which closed within the 24 hour window" do
    consultations = [
      create_consultation(closing_at: Time.new(2018, 3, 6, 2, 30, 0)), # 02:30 day before
      create_consultation(closing_at: Time.new(2018, 3, 6, 23, 45, 0)), # 23:45 day before
      create_consultation(closing_at: Time.new(2018, 3, 7, 0, 30, 0)), # 00:30 day of
    ]

    ConsultationReminder.send_all

    assert_equal 3, ActionMailer::Base.deliveries.size

    consultations.each do |consultation|
      assert ActionMailer::Base.deliveries.any? do |email|
        email.to.sort == consultation.authors.map(&:email).sort &&
          email.subject.includes?("response due in") &&
          email.body.includes?(consultation.title) &&
          email.body.includes?("within 4 weeks")
      end
    end
  end

  test ".send_all doesn't send notifications for consultations with 4 weeks left which closed on or before the 24 hour window" do
    create_consultation(closing_at: Time.new(2018, 3, 6, 0, 30, 0)) # 00:30 day before
    create_consultation(closing_at: Time.new(2018, 3, 6, 1, 0, 0)) # 01:00 day before
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?

    create_consultation(closing_at: Time.new(2018, 3, 6, 1, 1, 0)) # 01:01 day before
    ConsultationReminder.send_all
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test ".send_all doesn't send notifications for consultations with 4 weeks left which closed after the 24 hour window" do
    create_consultation(closing_at: Time.new(2018, 3, 7, 1, 1, 0)) # 01:01 day of
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?

    create_consultation(closing_at: Time.new(2018, 3, 7, 1, 0, 0)) # 01:00 day of
    ConsultationReminder.send_all
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test ".send_all doesn't send notifications for consultations with 4 weeks left which closed within the 24 hour window but have an outcome" do
    create_consultation(closing_at: Time.new(2018, 3, 6, 23, 45, 0), responded: true) # 23:45
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?
  end

  test ".send_all notifies authors of consultations with 1 week left without an outcome which closed within the 24 hour window" do
    consultations = [
      create_consultation(closing_at: Time.new(2018, 2, 13, 2, 30, 0)), # 02:30 day before
      create_consultation(closing_at: Time.new(2018, 2, 13, 23, 45, 0)), # 23:45 day before
      create_consultation(closing_at: Time.new(2018, 2, 14, 0, 30, 0)), # 00:30 day of
    ]

    ConsultationReminder.send_all

    assert_equal 3, ActionMailer::Base.deliveries.size

    consultations.each do |consultation|
      assert ActionMailer::Base.deliveries.any? do |email|
        email.to.sort == consultation.authors.map(&:email).sort &&
          email.subject.includes?("response due in") &&
          email.body.includes?(consultation.title) &&
          email.body.includes?("within 1 week")
      end
    end
  end

  test ".send_all doesn't send notifications for consultations with 1 week left which closed on or before the 24 hour window" do
    create_consultation(closing_at: Time.new(2018, 2, 13, 0, 30, 0)) # 00:30 day before
    create_consultation(closing_at: Time.new(2018, 2, 13, 1, 0, 0)) # 01:00 day before
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?

    create_consultation(closing_at: Time.new(2018, 2, 13, 1, 1, 0)) # 01:01 day before
    ConsultationReminder.send_all
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test ".send_all doesn't send notifications for consultations with 1 week left which closed after the 24 hour window" do
    create_consultation(closing_at: Time.new(2018, 2, 14, 1, 1, 0)) # 01:01 day of
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?

    create_consultation(closing_at: Time.new(2018, 2, 14, 1, 0, 0)) # 01:00 day of
    ConsultationReminder.send_all
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test ".send_all doesn't send notifications for consultations with 1 week left which closed within the 24 hour window but have an outcome" do
    create_consultation(closing_at: Time.new(2018, 2, 13, 23, 45, 0), responded: true) # 23:45 day before
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?
  end

  test ".send_all notifies authors of consultations without an outcome which became overdue within the last 24 hours" do
    consultations = [
      create_consultation(closing_at: Time.new(2018, 2, 6, 2, 30, 0)), # 02:30 day before
      create_consultation(closing_at: Time.new(2018, 2, 6, 23, 45, 0)), # 23:45 day before
      create_consultation(closing_at: Time.new(2018, 2, 7, 0, 30, 0)), # 00:30 day of
    ]

    ConsultationReminder.send_all

    assert_equal 3, ActionMailer::Base.deliveries.size

    consultations.each do |consultation|
      assert ActionMailer::Base.deliveries.any? do |email|
        email.to.sort == consultation.authors.map(&:email).sort &&
          email.subject.includes?("deadline has passed") &&
          email.body.includes?(consultation.title) &&
          email.body.includes?("deadline") &&
          email.body.includes?("has passed")
      end
    end
  end

  test ".send_all doesn't send notifications for consultations which became overdue on or before the last 24 hours" do
    create_consultation(closing_at: Time.new(2018, 2, 6, 0, 30, 0)) # 00:30 day before
    create_consultation(closing_at: Time.new(2018, 2, 6, 1, 0, 0)) # 01:00 day before
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?

    create_consultation(closing_at: Time.new(2018, 2, 6, 1, 1, 0)) # 01:01 day before
    ConsultationReminder.send_all
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test ".send_all doesn't send notifications for consultations became overdue after the last 24 hours" do
    create_consultation(closing_at: Time.new(2018, 2, 7, 1, 1, 0)) # 01:01 day of
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?

    create_consultation(closing_at: Time.new(2018, 2, 7, 1, 0, 0)) # 01:00 day of
    ConsultationReminder.send_all
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test ".send_all doesn't send notifications for consultations which became overdue within the last 24 hours but have an outcome" do
    create_consultation(closing_at: Time.new(2018, 2, 6, 23, 45, 0), responded: true) # 23:45 day before
    ConsultationReminder.send_all
    assert ActionMailer::Base.deliveries.empty?
  end

  test ".send_all only notifies authors once" do
    author = FactoryBot.create(:author)
    consultation = FactoryBot.create(
      :consultation,
      opening_at: 10.months.ago,
      closing_at: Time.new(2018, 3, 6, 23, 45, 0),
    )
    consultation.update(authors: [author, author])

    ConsultationReminder.send_all

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal [author.email], ActionMailer::Base.deliveries.first.to
  end

  def create_consultation(closing_at:, responded: false)
    type = responded ? :consultation_with_outcome : :consultation
    FactoryBot.create(type, opening_at: 10.months.ago, closing_at: closing_at)
  end
end
