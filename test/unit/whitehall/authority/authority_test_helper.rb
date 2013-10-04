module AuthorityTestHelper
  def enforcer_for(actor, subject)
    Whitehall::Authority::Enforcer.new(actor, subject)
  end

  def with_locations(edition, world_locations)
    edition.stubs(:world_locations).returns(world_locations)
    edition
  end
end

if defined? Rails
  # if we've already loaded rails, no point jumping through hoops to avoid it
  require 'test_helper'

  module AuthorityTestHelper
    def self.define_edition_factory_methods(edition_type)
      define_method("normal_#{edition_type}") do |user = nil|
        ne = FactoryGirl.build(edition_type)
        ne.stubs(:creator).returns(user)
        ne
      end
      define_method("force_published_#{edition_type}") do |user|
        fpe = FactoryGirl.build(:"published_#{edition_type}", force_published: true)
        fpe.stubs(:published_by).returns(user)
        fpe
      end
      define_method("limited_#{edition_type}") do |orgs|
        le = FactoryGirl.build(edition_type, access_limited: true)
        le.stubs(:edition_organisations).returns(Array.wrap(orgs).map { |o|
          OpenStruct.new(organisation: o)
        })
        le
      end
      define_method("scheduled_#{edition_type}") do
        FactoryGirl.build(:"scheduled_#{edition_type}").tap do |scheduled_edition|
          scheduled_edition.stubs(:scheduled?).returns(true)
        end
      end
    end

    define_edition_factory_methods :edition
    define_edition_factory_methods :fatality_notice
    define_edition_factory_methods :world_location_news_article
    define_edition_factory_methods :worldwide_priority
  end
else
  # otherwise use the fast_test_helper and fake things out a bit
  require 'fast_test_helper'
  require 'whitehall/authority'

  module AuthorityTestHelper
    def self.get_class_name_from_type(edition_type)
      edition_type.to_s.gsub('_',' ').split().map(&:capitalize).join
    end

    def self.get_class_from_type(edition_type)
      Object.const_get(get_class_name_from_type(edition_type))
    end

    def self.define_edition_factory_methods(edition_type)
      define_method("normal_#{edition_type}") do |user = nil|
        AuthorityTestHelper.get_class_from_type(edition_type).new(user)
      end
      define_method("force_published_#{edition_type}") do |user|
        AuthorityTestHelper.get_class_from_type(edition_type).new(nil, true, user)
      end
      define_method("limited_#{edition_type}") do |orgs|
        e = AuthorityTestHelper.get_class_from_type("limited_#{edition_type}").new
        e.edition_organisations = Array.wrap(orgs || []).map { |o|
          OpenStruct.new(organisation: o)
        }
        e
      end
      define_method("scheduled_#{edition_type}") do
        AuthorityTestHelper.get_class_from_type(edition_type).new(nil, false, nil, true)
      end
    end

    define_edition_factory_methods :edition
    define_edition_factory_methods :fatality_notice
    define_edition_factory_methods :world_location_news_article
    define_edition_factory_methods :worldwide_priority
  end

  class EditionBase < Struct.new(:creator, :force_published, :published_by, :scheduled);
    def force_published?
      !!@force_published
    end
    def access_limited?
      false
    end
    def edition_organisations
      []
    end
    def scheduled?
      scheduled
    end
  end

  module AuthorityTestHelper
    def self.define_edition_classes(edition_type)
      class_name = get_class_name_from_type(edition_type)
      unless Object.const_defined? class_name
        base = class_name == 'Edition' ? EditionBase : Edition
        new_edition_class = Object.const_set(class_name, Class.new(base))
        Object.const_set("Limited#{class_name}", Class.new(new_edition_class) do
          def access_limited?
            true
          end
          def edition_organisations=(edition_orgs)
            @edition_orgs = edition_orgs
          end
          def edition_organisations
            @edition_orgs
          end
        end)
      end
    end
  end
  AuthorityTestHelper.define_edition_classes :edition
  AuthorityTestHelper.define_edition_classes :fatality_notice
  AuthorityTestHelper.define_edition_classes :world_location_news_article
  AuthorityTestHelper.define_edition_classes :worldwide_priority

  class Document; end
  class MinisterialRole; end
  class PolicyAdvisoryGroup; end
end
