module MiniMongo::Document
  extend ActiveSupport::Concern

  include MiniMongo::Persistance
  include MiniMongo::Dirty
  
  included do
    extend ActiveModel::Callbacks
    define_model_callbacks :insert, :update, :remove
  end

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

    def count
      collection.count
    end

    private
      def options_for_find(query = {}, options = {})
        options.reverse_merge!({
          transformer: lambda { |doc| new(doc, true) }
        })
        [query, options]
      end
  end
end
