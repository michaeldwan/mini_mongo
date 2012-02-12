class Hash
  def deep_stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
      if self[key.to_s].is_a?(Hash)
        self[key.to_s].deep_stringify_keys!
      end
    end
    self
  end
end
