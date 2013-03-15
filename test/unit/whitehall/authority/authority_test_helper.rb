require 'fast_test_helper'
require 'whitehall/authority'
require 'ostruct'

# so we don't have to require the real editions and slow these tests
# right down
class Edition < Struct.new(:creator, :force_published, :published_by);
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
  def normal_edition(user=nil)
    Edition.new(user)
  end

  def force_published_edition(user)
    Edition.new(nil, true, user)
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

