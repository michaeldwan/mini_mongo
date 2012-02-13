unless defined?(Mongo)
  require "mongo"
end

require 'active_support/concern'
require 'active_model'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/inflections'
require 'active_support/core_ext/object/blank'

module MiniMongo
  class << self
    def db
      raise ConfigurationError, "No database set" if @db.blank?
      @db
    end
    
    def db=(db)
      raise(ArgumentError, "Must supply a Mongo::DB object") unless db.is_a?(Mongo::DB)  
      @db = db
    end
  end

  class MiniMongoError        < RuntimeError; end
  class AlreadyInsertedError  < MiniMongoError; end
  class NotInsertedError      < MiniMongoError; end
  class InsertError           < MiniMongoError; end
  class StaleUpdateError      < MiniMongoError; end
  class UpdateError           < MiniMongoError; end
  class RemoveError           < MiniMongoError; end
  class DuplicateKeyError     < MiniMongoError; end
  class ModifierUpdateError   < MiniMongoError; end
  class ConfigurationError    < MiniMongoError; end

  class ValidationError < MiniMongoError
    attr_reader :errors
    def initialize(errors)
      @errors = errors
    end

    def to_s
      errors.map { |field, message| message }.join(", ")
    end
  end
  
end

require_relative "core_ext/hash"
require_relative "mini_mongo/document/persistance"
require_relative "mini_mongo/document/dirty"
require_relative "mini_mongo/document/modifications"
require_relative "mini_mongo/document/validation_errors"
require_relative "mini_mongo/document"
require_relative "mini_mongo/dot_hash"
