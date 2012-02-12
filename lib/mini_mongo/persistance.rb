module MiniMongo::Persistance
  extend ActiveSupport::Concern

  def persisted?
    @persisted == true
  end

  def removed?
    @removed == true
  end

  def new?
    !persisted? && !removed?
  end

  def reload(new_doc = nil)
    new_doc ||= collection.find_one(self["_id"])
    set_document(new_doc)
    @persisted = true
    clear_snapshot
    true
  end

  def save(*args)
    persisted? ? update(*args) : insert(*args)
  end

  def save!(*args)
    persisted? ? update!(*args) : insert!(*args)
  end

  def insert(options = {})
    raise AlreadyInsertedError, "document has already been inserted" if persisted?

    response = run_callbacks :insert do
      # validation?
      response = collection.insert(document.to_hash, options)
      unless response.is_a?(BSON::ObjectId)
        raise InsertError, "not an object: #{ret.inspect}"
      end
      document.dot_set("_id", response) if document["_id"].blank?
      @persisted = true
      clear_snapshot
      response
    end
    response
  rescue Mongo::OperationFailure => e
    if e.message.to_s =~ /^11000\:/
      raise MiniMongo::DuplicateKeyError, e.message
    else
      raise e
    end
  end

  def insert!(options = {})
    insert(options.merge(:safe => true))
  end

  def update(options = {})
    return false unless dirty?

    raise NotInsertedError, "document must be inserted before being updated" unless persisted?

    run_callbacks :update do
      # validation?
      only_if_current = options.delete(:only_if_current)
      options[:safe] = true if !options[:safe] && only_if_current
      selector = self.class.build_update_selector(self.to_oid, changes, only_if_current)
      updates = self.class.build_update_hash(changes)

      if options.delete(:find_and_modify) == true
        response = self.collection.find_and_modify(query: selector, update: updates, new: true)
        reload(response)
      else
        response = collection.update(selector, updates, options)
        if !response.is_a?(Hash) || (response["updatedExisting"] && response["n"] == 1)
          clear_snapshot
          true
        else
          if only_if_current
            raise StaleUpdateError, response.inspect
          else
            raise MiniMongo::UpdateError, response.inspect
          end
        end
      end
    end
  rescue Mongo::OperationFailure => e
    if e.message.to_s =~ /^11000\:/
      raise DuplicateKeyError, e.message
    else
      raise e
    end
  end

  def update!(opts={})
    update(opts.merge(:safe => true))
  end

  def remove(options = {})
    raise NotInsertedError, "document must be inserted before it can be removed" unless persisted?

    run_callbacks :remove do
      response = collection.remove({_id: self[:_id]}, options)
      if !response.is_a?(Hash) || (response["err"] == nil && response["n"] == 1)
        @removed = true
        @persisted = false
        clear_snapshot
        true
      else
        raise MiniMongo::RemoveError, response.inspect
      end
    end
  end

  def remove!(options = {})
    remove(options.merge(:safe => true))
  end

  module ClassMethods

  # protected

    def build_update_hash(changes)
      update_hash = Hash.new { |h, k| h[k] = {} }

      changes.each do |key, change|
        if change[1].blank?
          update_hash["$unset"][key] = 1
        else
          update_hash["$set"][key] = change[1]
        end
      end
      update_hash
    end

    def build_update_selector(id, changeset, only_if_current = false)
      selector = {"_id" => id}
      return selector unless only_if_current
      changes.each do |key, change|
        if change[0].present?
          if persisted_val == []
            # work around a bug where mongo won't find a doc
            # using an empty array [] if an index is defined
            # on that field.
            persisted_val = { "$size" => 0 }
          end
          selector[k] = persisted_val
        end
      end
      selector
    end
  end
end
