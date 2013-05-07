require 'test_helper'

class EmailSignup::AlertTest < ActiveSupport::TestCase
  test 'is invalid if the topic is missing' do
    a = EmailSignup::Alert.new(topic: '')
    a.valid?
    refute a.errors[:base].empty?
  end

  test 'is invalid if the topic is not the slug of a topic from EmailSignup.valid_topics_by_type' do
    topics_by_type = {topic: [stub(slug: 'woo')], topical_event: []}
    EmailSignup.stubs(:valid_topics_by_type).returns topics_by_type
    a = EmailSignup::Alert.new(topic: 'meh')
    a.valid?
    refute a.errors[:topic].empty?
  end

  test 'is valid if the topic is "all" (even if that is not the slug of a topic from EmailSignup.valid_topics_by_type)' do
    topics_by_type = {topic: [stub(slug: 'woo')], topical_event: []}
    EmailSignup.stubs(:valid_topics_by_type).returns topics_by_type
    a = EmailSignup::Alert.new(topic: 'all')
    a.valid?
    assert a.errors[:topic].empty?
  end

  test 'is invalid if the organisation is missing' do
    a = EmailSignup::Alert.new(organisation: '')
    a.valid?
    refute a.errors[:base].empty?
  end

  test 'is invalid if the organisation is not the slug of a organisation from EmailSignup.valid_organisations_by_type' do
    EmailSignup.stubs(:valid_organisations_by_type).returns({ministerial: [stub(slug: 'woo')], other: [stub(slug: 'foo')]})
    a = EmailSignup::Alert.new(organisation: 'meh')
    a.valid?
    refute a.errors[:organisation].empty?
  end

  test 'is valid if the organisation is "all" (even if that is not the slug of an organisation from EmailSignup.valid_organisations_by_type)' do
    EmailSignup.stubs(:valid_organisations_by_type).returns({ministerial: [stub(slug: 'woo')], other: [stub(slug: 'foo')]})
    a = EmailSignup::Alert.new(organisation: 'all')
    a.valid?
    assert a.errors[:organisation].empty?
  end

  test 'is invalid if the document_type is missing' do
    a = EmailSignup::Alert.new(document_type: '')
    a.valid?
    refute a.errors[:base].empty?
  end

  test 'is invalid if the document_type is not the type-prefixed slug of a document_type from EmailSignup.valid_document_types_by_type' do
    EmailSignup.stubs(:valid_document_types_by_type).returns({publication_type: [stub(slug: 'woo')], announcment_type: [stub(slug: 'foo')]})
    a = EmailSignup::Alert.new(document_type: 'publication_type_meh')
    a.valid?
    refute a.errors[:document_type].empty?
  end

  test 'is valid if the document_type is "all" (even if that is not the type-prefixed slug of a document_type from EmailSignup.valid_document_types_by_type)' do
    EmailSignup.stubs(:valid_document_types_by_type).returns({publication_type: [stub(slug: 'woo')], announcment_type: [stub(slug: 'foo')]})
    a = EmailSignup::Alert.new(document_type: 'all')
    a.valid?
    assert a.errors[:document_type].empty?
  end

  test 'is valid if there is a policy' do
    EmailSignup.stubs(:valid_policy_slugs).returns(['test'])
    a = EmailSignup::Alert.new(policy: 'test')
    a.valid?
    assert a.errors[:policy].empty?
  end

  # NOTE: this is the behaviour of activerecord's boolean column
  # conversion, which we've copied rather than used directly, hence the
  # explicit testing
  test 'converts 1, "1", "t", "true", and "TRUE" to proper boolean true for info_for_local' do
    [1, "1", "t", "true", "TRUE"].each do |truthy|
      a = EmailSignup::Alert.new(info_for_local: truthy)
      assert_equal true, a.info_for_local, "expected '#{truthy}' to be true, but it wasn't"
    end
  end

  test 'treats a blank string, or nil info_for_local as nil' do
    ['', ' ', nil].each do |nilly|
      a = EmailSignup::Alert.new(info_for_local: nilly)
      assert_nil a.info_for_local, "expected '#{nilly}' to be nil, but it wasn't"
    end
  end

  test 'anything elase for info_for_local as proper boolean false' do
    ['blah', 12, 0, 'false', Date.today].each do |falsy|
      a = EmailSignup::Alert.new(info_for_local: falsy)
      assert_equal false, a.info_for_local, "expected '#{falsy}' to be false, but it wasn't"
    end
  end

  test 'extracts the generic type from the prefix of the document_type' do
    assert_equal 'publication', EmailSignup::Alert.new(document_type: 'publication_type_consultations').document_generic_type
    assert_equal 'policy', EmailSignup::Alert.new(document_type: 'policy_type_all').document_generic_type
    assert_equal 'announcement', EmailSignup::Alert.new(document_type: 'announcement_type_speehches').document_generic_type
  end

  test 'when the document_type is all, the generic type is also all' do
    assert_equal 'all', EmailSignup::Alert.new(document_type: 'all').document_generic_type
  end

  test 'extracts the specific type from the suffix of the document_type' do
    assert_equal 'consultations', EmailSignup::Alert.new(document_type: 'publication_type_consultations').document_specific_type
    assert_equal 'all', EmailSignup::Alert.new(document_type: 'policy_type_all').document_specific_type
    assert_equal 'speeches', EmailSignup::Alert.new(document_type: 'announcement_type_speeches').document_specific_type
  end

  test 'when the document_type is all, the specific type is also all' do
    assert_equal 'all', EmailSignup::Alert.new(document_type: 'all').document_specific_type
  end
end
