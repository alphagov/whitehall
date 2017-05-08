class FeatureFlag < ApplicationRecord
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

  def self.destroy(key)
    if flag = find_by(key: key)
      flag.destroy
    end
  end
end
