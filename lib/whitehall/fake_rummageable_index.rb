module Whitehall
  class FakeRummageableIndex < Rummageable::Index
    class << self
      attr_accessor :store
    end
    @store = nil

    def initialize(url, name, options = {})
      super
      @index_name = name
    end

    def add(entry)
      add_batch([entry])
    end

    def add_batch(entries)
      store.add(entries, @index_name) if store.present?
    end

    def delete(link)
      store.delete(link, @index_name) if store.present?
    end

    def make_request(_method, *_args)
      raise "Use the in memory index (rather than rummager) in tests"
    end

  private

    def store
      self.class.store
    end
  end
end
