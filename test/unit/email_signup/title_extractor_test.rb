require 'test_helper'

class EmailSignup::TitleExtractorTest < ActiveSupport::TestCase
  test 'given an alert with a document_type of "publication_type_all" the title starts "All publications"' do
    a = EmailSignup::Alert.new(document_type: 'publication_type_all')
    assert_match(/\AAll publications/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with a document_type prefixed with "publication_type_" but not "publication_type_all" the title should start with the label of the PublicationFilterOption with that slug' do
    a = EmailSignup::Alert.new(document_type: 'publication_type_consultations')
    assert_match(/\A#{Whitehall::PublicationFilterOption::Consultation.label}/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with a document_type of "announcement_type_all" the title starts "All announcements"' do
    a = EmailSignup::Alert.new(document_type: 'announcement_type_all')
    assert_match(/\AAll announcements/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with a document_type prefixed with "announcement_type_" but not "announcement_type_all" the title should start with the label of the AnouncementFilterOption with that slug' do
    a = EmailSignup::Alert.new(document_type: 'announcement_type_speeches')
    assert_match(/\A#{Whitehall::AnnouncementFilterOption::Speech.label}/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with a document_type of "policy_type_all" the title starts "All policies"' do
    a = EmailSignup::Alert.new(document_type: 'policy_type_all')
    assert_match(/\AAll policies/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with a document_type of "all" the title starts "All documents"' do
    a = EmailSignup::Alert.new(document_type: 'all')
    assert_match(/\AAll types of document/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with an organisation of "all" the title should end with "by all organisations"' do
    a = EmailSignup::Alert.new(document_type: 'all', organisation: 'all')
    assert_match(/ by all organisations\Z/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with an organisation not "all" the url should end with "by <the name of the org with that slug>"' do
    org = create(:organisation, name: 'Dept. of Embalming Crotchety Camels')
    org.update_column(:slug, 'decc')
    a = EmailSignup::Alert.new(document_type: 'all', organisation: 'decc')
    assert_match(/ by #{Regexp.escape(org.name)}\Z/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with a topic of "all" the title should include "about all topics"' do
    a = EmailSignup::Alert.new(document_type: 'all', topic: 'all')
    assert_match(/ about all topics/, EmailSignup::TitleExtractor.new(a).title)
  end

  test 'given an alert with an topic not "all" the title should include "about <name of topic with that slug>"' do
    topic = create(:topic, name: 'the environment')
    topic.update_column(:slug, 'environment')
    a = EmailSignup::Alert.new(document_type: 'all', topic: 'environment')
    assert_match(/ about the environment/, EmailSignup::TitleExtractor.new(a).title)
  end
end
