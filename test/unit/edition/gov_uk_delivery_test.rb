# encoding: utf-8

require "test_helper"

class Edition::GovUkDeliveryTest < ActiveSupport::TestCase
  class EditionWithGovUkDelivery < Edition
    include Edition::GovUkDelivery
  end

  def edition_with_gov_uk_delivery
    o = create(:organisation)
    EditionWithGovUkDelivery.new(
      title:   'edition-title',
      body:    'edition-body',
      summary: 'edition-summary',
      creator: build(:user),
      lead_organisations: [o]
    )
  end

  test 'is only included in Annoucement, Publicationesque, and Policy edition types (and their descendants)' do
    govuk_delivery_edition_types = [Announcement, Publicationesque, Policy]
    govuk_delivery_edition_types += govuk_delivery_edition_types.map(&:descendants).flatten

    govuk_delivery_edition_types.each do |govuk_delivery_edition_type|
      assert govuk_delivery_edition_type.ancestors.include?(Edition::GovUkDelivery), "Expected #{govuk_delivery_edition_type.name} to include Edition::GovUkDelivery, but it doesn't"
    end

    (Edition.descendants - govuk_delivery_edition_types - [EditionWithGovUkDelivery]).each do |edition_type|
      refute edition_type.ancestors.include?(Edition::GovUkDelivery), "#{edition_type} includes Edition::GovUkDelivery, but it shouldn't"
    end
  end

  test "notifies when publishing editions with govukdelivery mixed in" do
    Edition::AuditTrail.whodunnit = create(:user)

    notifiable_edition = edition_with_gov_uk_delivery
    notifiable_edition.first_published_at = Time.zone.now
    notifiable_edition.major_change_published_at = Time.zone.now

    notifier = Whitehall::GovUkDelivery::Notifier.new(notifiable_edition)
    Whitehall::GovUkDelivery::Notifier.expects(:new).with(notifiable_edition).returns(notifier)
    notifier.expects(:edition_published!).once
    notifiable_edition.perform_force_publish
  end
end
