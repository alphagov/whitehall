module ActiveRecordLikeInterface
  module ClassMethods
    def primary_key
      :id
    end

    def repository
      @repository ||= {}
    end

    def find_by_id(id)
      repository[id]
    end

    def all
      repository.values
    end

    def create(*args)
      new(*args).save
    end
  end

  def initialize(options={})
    options.each do |key, value|
      self[key] = value
    end
  end

  def [](key)
    __send__(key)
  end

  def []=(key, value)
    __send__("#{key}=", value)
  end

  def save
    self.class.repository[id] = self
  end

  def destroyed?
    false
  end

  def new_record?
    false
  end

  def to_param
    id && id.to_s
  end

  def self.included(into)
    into.extend ClassMethods
  end
end
