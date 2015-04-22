class FeatureFlag < ActiveRecord::Base
  def self.set(key, value)
    flag = find_by!(key: key)
    flag.update(enabled: value)
  end

  def self.enabled?(name)
    if flag = find_by(key: name)
      flag.enabled
    else
      false
    end
  end
end
