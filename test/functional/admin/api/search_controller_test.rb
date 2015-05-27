require 'test_helper'

class Admin::Api::SearchControllerTest < ActionController::TestCase
  def setup
    login_as :user

    @relevant_editions = [
      # Published with correct primary tag
      FactoryGirl.create(:publication, :published, primary_specialist_sector_tag: 'oil-and-gas/licensing'),
      # Published with correct secondary tag
      FactoryGirl.create(:detailed_guide, :published, secondary_specialist_sector_tags: ['oil-and-gas/licensing'])
    ]

    @irrelevant_editions = [
      # Correct tag, but draft
      FactoryGirl.create(:publication, :draft, primary_specialist_sector_tag: 'oil-and-gas/licensing'),
      # Correct tag, but withdrawn
      FactoryGirl.create(:publication, :withdrawn, primary_specialist_sector_tag: 'oil-and-gas/licensing'),
      # Published, but incorrect tag
      FactoryGirl.create(:publication, :published, secondary_specialist_sector_tags: ['environmental-management/boating']),
      # Published, but no tag
      FactoryGirl.create(:publication, :published)
    ]
  end

  test "#reindex_specialist_sector reindexes all published editions tagged to the specialist sector" do
    @relevant_editions.each do |edition|
      Whitehall::SearchIndex.expects(:add).with(edition).once
    end

    @irrelevant_editions.each do |edition|
      Whitehall::SearchIndex.expects(:add).with(edition).never
    end

    post :reindex_specialist_sector_editions,
      {slug: 'oil-and-gas/licensing'},
      {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
  end
end
