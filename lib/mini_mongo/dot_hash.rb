require "forwardable"

class MiniMongo::DotHash
  extend Forwardable

  def_delegators :@raw_hash, :==, :[], :[], :[]=, :clear, :default, :default=, :default_proc, :delete, :delete_if,
                 :each, :each_key, :each_pair, :each_value, :empty?, :fetch, :has_key?, :has_value?, :include?,
                 :index, :indexes, :indices, :initialize_copy, :inspect, :invert, :key?, :keys, :length, :member?,
                 :merge, :merge!, :pretty_print, :pretty_print_cycle, :rehash, :reject, :reject!, :replace, :select,
                 :shift, :size, :sort, :store, :to_a, :to_hash, :to_s, :update, :value?, :values, :values_at

  attr_reader :raw_hash

  def initialize(hash = {})
    @raw_hash = hash.to_hash.deep_stringify_keys!
  end

  def dot_set(key, value)
    if value.nil?
      dot_delete(key)
    end
    parts = key.to_s.split(".")
    current_value = to_hash
    while !parts.empty?
      part = parts.shift
      if parts.empty?
        current_value[part] = value
      else
        current_value[part] ||= {}
        current_value = current_value[part]
      end
    end
    true
  end

  def dot_get(key)
    if value = raw_hash[key]
      return value
    end

    parts = key.to_s.split(".")
    current_value = to_hash
    while !parts.empty?
      part = parts.shift
      if sub_value = extract(current_value, part)
        current_value = sub_value
      else
        return nil
      end
    end
    current_value
  end

  def dot_delete(key)
    parts = key.to_s.split(".")
    current_value = to_hash
    while !parts.empty?
      part = parts.shift
      if parts.empty?
        current_value.delete(part)
        return true
      else
        current_value = current_value[part]
      end
    end
    false
  end

  def dot_list(curr_hash=self.to_hash, path=[])
    list = []
    curr_hash.each do |k,v|
      if v.is_a?(Hash)
        list.concat dot_list(v, (path + [k]))
      else
        list << (path + [k]).join(".")
      end
    end
    list
  end

  def to_key_value
    kv = {}; dot_list.collect { |k| kv[k] = dot_get(k) }; kv
  end

  private
    def extract(object, key)
      if object.is_a?(Hash)
        object[key]
      elsif object.respond_to?(:map)
        object.map { |sub_object| sub_object[key] }.flatten
      end
    end
end
