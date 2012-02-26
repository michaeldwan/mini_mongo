module MiniMongo::Document
  extend ActiveSupport::Concern

  include MiniMongo::Concerns::Callbacks
  include MiniMongo::Concerns::Persistance
  include MiniMongo::Concerns::Dirty
  include MiniMongo::Concerns::Modifications
  include MiniMongo::Concerns::Validation
  include MiniMongo::Concerns::Serialization

  def initialize(hash = {}, persisted = false)
    if hash[:_id].blank? && hash["_id"].blank?
      hash.reverse_merge!("_id" => collection.pk_factory.new)
    end
    set_document(hash)
    @persisted = persisted
  end

  def document
    @document
  end

  def [](key)
    @document.dot_get(key.to_s)
  end

  def []=(key, value)
    snapshot
    @document.dot_set(key.to_s, value)
  end

  def collection
    self.class.collection
  end

  def set_document(hash)
    hash = MiniMongo::DotHash.new(hash) unless hash.is_a?(MiniMongo::DotHash)
    @document = hash
  end

  def id
    self["_id"]
  end

  def to_oid
    self["_id"]
  end

  def ==(other)
    return false unless self.class == other.class
    self.id == other.id
  end

  def to_hash
    document.to_hash
  end

  def merge!(hash)
    snapshot
    hash = MiniMongo::DotHash.new(hash) unless hash.is_a?(MiniMongo::DotHash)
    set_document(MiniMongo::DotHash.new(document.raw_hash.deep_merge(hash)))
    document
  end

  def has_key?(key)
    !document[key].nil?
  end

  def inspect
    "<#{self.class.name} #{attributes_for_inspect.map {|k, v| "#{k}:#{v}"}.join(", ")}>"
  end

  def attributes_for_inspect
    to_hash
  end
  protected :attributes_for_inspect

  module ClassMethods
    def db
      @db || MiniMongo.db || nil
    end

    def db=(db)
      raise(ArgumentError, "Must supply a Mongo::DB object") unless db.is_a?(Mongo::DB)
      @db = db
    end
    
    def collection_name
      self.to_s.tableize
    end

    def collection
      @collection ||= self.db.collection(self.collection_name)
    end

    def find(query = {}, options = {})
      collection.find(*options_for_find(query, options))
    end

    def find_one(query = {}, options = {})
      collection.find_one(*options_for_find(query, options))
    end
    alias :first :find_one

    def distinct(key, query = {})
      collection.distinct(key, options_for_find(query).first)
    end

    def count(query = {})
      collection.find(query).count
    end

    private
      def options_for_find(query = {}, options = {})
        options.reverse_merge!({
          transformer: lambda { |doc| new(doc, true) }
        })

        if options[:sort] && options[:sort].is_a?(Hash)
          options[:sort] = options[:sort].to_a
        end

        [query, options]
      end
  end
end
