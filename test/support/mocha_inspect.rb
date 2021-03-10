class ActiveRecord::Base
  def self.mocha_inspect
    inspect.sub(%r{\([^)]+\)}, "")
  end
end
