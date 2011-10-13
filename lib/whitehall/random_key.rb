require 'whitehall'

module Whitehall::RandomKey
  extend ActiveSupport::Concern

  def initialize(*args, &block)
    super
    write_attribute(:key, self.class.unique_random_key)
  end

  def to_param
    key
  end

  def key=(key)
  end

  module ClassMethods
    def key_used?(key)
      where(key: key).exists?
    end

    def unique_random_key
      key = random_key while key.nil? || key_used?(key)
      key
    end

    def random_key
      Whitehall::Random.base32(8)
    end

    def from_param(key)
      where(key: key).first
    end
  end
end