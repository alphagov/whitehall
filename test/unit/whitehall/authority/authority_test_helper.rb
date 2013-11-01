module AuthorityTestHelper
  def enforcer_for(actor, subject)
    Whitehall::Authority::Enforcer.new(actor, subject)
  end

  def with_locations(edition, world_locations)
    edition.stubs(:world_locations).returns(world_locations)
    edition
  end
end

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
      le.stubs(:organisations).returns(orgs)
      le
    end
    define_method("scheduled_#{edition_type}") do
      FactoryGirl.build(:"scheduled_#{edition_type}").tap do |scheduled_edition|
        scheduled_edition.stubs(:scheduled?).returns(true)
      end
    end
    define_method("force_scheduled_#{edition_type}") do |user|
      fse = FactoryGirl.build(:"scheduled_#{edition_type}", force_published: true)
      fse.stubs(:scheduled_by).returns(user)
      fse
    end
  end

  define_edition_factory_methods :edition
  define_edition_factory_methods :publication
  define_edition_factory_methods :fatality_notice
  define_edition_factory_methods :world_location_news_article
  define_edition_factory_methods :worldwide_priority
end
