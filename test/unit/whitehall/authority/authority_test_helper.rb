require 'fast_test_helper'

module Whitehall
  module Authority
  end
end
require 'whitehall/authority/enforcer'
require 'ostruct'

# so we don't have to require the real editions and slow these tests
# right down
class Edition < Struct.new(:state, :force_published, :creator);
  def force_published?
    !!@force_published
  end
  def access_limited?
    false
  end
  def organisations
    []
  end
end

class LimitedEdition < Edition
  def access_limited?
    true
  end
  def organisations=(orgs)
    @orgs = orgs
  end
  def organisations
    @orgs
  end
end

class Document; end

module AuthorityTestHelper
  def normal_edition
    Edition.new
  end

  def submitted_edition
    Edition.new('submitted')
  end

  def force_published_edition(user)
    Edition.new('published', true, user)
  end

  def limited_edition(orgs)
    e = LimitedEdition.new
    e.organisations = (orgs || [])
    e
  end

  def enforcer_for(actor, subject)
    Whitehall::Authority::Enforcer.new(actor, subject)
  end
end

