require 'test_helper'

module PublishingApi::CorporateInformationPagePresenterTest
  class TestCase < ActiveSupport::TestCase
    attr_accessor :corporate_information_page, :update_type

    def presented_corporate_information_page
      PublishingApi::CorporateInformationPagePresenter.new(
        corporate_information_page,
        update_type: update_type,
      )
    end

    def presented_content
      presented_corporate_information_page.content
    end

    def assert_attribute(attribute, value)
      assert_equal value, presented_content[attribute]
    end
  end

  class BasicCorporateInformationPageTest < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page)
    end

    test 'base' do
      attributes_double = {
        base_attribute_one: 'base_attribute_one',
        base_attribute_two: 'base_attribute_two',
        base_attribute_three: 'base_attribute_three',
      }

      PublishingApi::BaseItemPresenter
        .expects(:new)
        .with(corporate_information_page)
        .returns(stub(base_attributes: attributes_double))

      actual_content = presented_content
      expected_content = actual_content.merge(attributes_double)

      assert_equal actual_content, expected_content
    end

    test 'schema name' do
      assert_attribute :schema_name, 'corporate_information_page'
    end

    test 'validity' do
      skip
      assert_valid_against_schema presented_content, 'corporate_information_page'
    end
  end

  class CorporateInformationPageWithMajorChange < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page,
                                               minor_change: false)
      self.update_type = 'major'
    end

    test 'update type' do
      assert_equal 'major', presented_corporate_information_page.update_type
    end
  end

  class CorporateInformationPageWithMinorChange < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page,
                                               minor_change: true)
    end

    test 'update type' do
      assert_equal 'minor', presented_corporate_information_page.update_type
    end
  end

  class CorporateInformationPageWithoutMinorChange < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page,
                                               minor_change: false)
    end

    test 'update type' do
      assert_equal 'major', presented_corporate_information_page.update_type
    end
  end
end
