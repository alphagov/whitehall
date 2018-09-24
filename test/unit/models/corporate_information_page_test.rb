require 'test_helper'

class CorporateInformationPageTest < ActiveSupport::TestCase
  test "creating a new corporate information page republishes the owning organisation" do
    test_object = create(:organisation)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    create(:corporate_information_page, organisation: test_object)
  end

  test "updating an existing corporate information page republishes the owning organisation" do
    test_object = create(:organisation)
    corporate_information_page = create(:corporate_information_page, organisation: test_object)
    corporate_information_page.external = true
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    corporate_information_page.save!
  end

  test "deleting a corporate information page republishes the owning organisation" do
    test_object = create(:organisation)
    corporate_information_page = create(:corporate_information_page, organisation: test_object)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    corporate_information_page.destroy
  end

  test "corporate information pages cannot be previously published" do
    refute build(:corporate_information_page).previously_published
  end
end
