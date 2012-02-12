module MiniMongo::Persistance
  def persisted?
    @persisted == true
  end

  def dirty?
    # should it actually compare the data?
    @snapshot.present?
  end

  def removed?
    @removed == true
  end

  def new_record?
    !persisted?
  end

  def changeset
    return unless dirty?
    persisted_hash = (self.snapshot_data || MiniMongo::DotHash.new).to_key_value
    current_hash = self.document.to_key_value
    
    log = []
    
    persisted_hash.each do |k,v|
      unless current_hash.has_key?(k)
        found = nil
        parts = k.split(".")
        while parts.pop
          if !self.document.dot_get(parts.join("."))
            found = [:unset, parts.join("."), 1]
          end
        end
        found ||= [:unset, k, 1]
        log << found
      end
    end
    
    current_hash.each do |k,v|
      if v != persisted_hash[k]
        unless log.include?([:set, k, v])
          log << [:set, k, v]
        end
      end
    end
    
    log.uniq
  end

  def reload(new_doc = nil)
    new_doc ||= collection.find_one(self["_id"])
    set_document(new_doc)
    @persisted = true
    clear_snapshot
    true
  end

  def insert(options = {})
    raise AlreadyInsertedError, "document has already been inserted" if persisted?

    response = run_callbacks :insert do
      # validation?
      response = collection.insert(document, options)
      unless response.is_a?(BSON::ObjectId)
        raise InsertError, "not an object: #{ret.inspect}"
      end
      document.dot_set("_id", response)
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
    raise NotInsertedError, "document must be inserted before being updated" unless persisted?

    changeset = self.changeset
    return true if changeset.blank?

    run_callbacks :update do
      # validation?
      only_if_current = options.delete(:only_if_current)
      options[:safe] = true if !options[:safe] && only_if_current
      selector = build_selector(snapshot_data.to_key_value, changeset, only_if_current)
      updates = build_update_hash(changeset)

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
            raise StaleUpdateError, ret.inspect
          else
            raise MiniMongo::UpdateError, ret.inspect
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

  # protected
    def snapshot
      return if @snapshot
      @snapshot = Marshal.dump(self.document)
      true
    end

    def snapshot_data
      @snapshot_data ||= begin
        Marshal.load(@snapshot) if @snapshot
      end
    end

    def clear_snapshot
      @snapshot = nil
    end

    def build_update_hash(changeset)
      update_hash = Hash.new { |h, k| h[k] = {} }

      changeset.each do |operation, key, value|
        update_hash["$#{operation}"][key] = value
      end
      update_hash
    end

    def build_selector(persisted_document, changeset, only_if_current = false)
      update_selector = {"_id" => persisted_document["_id"]}
      return update_selector unless only_if_current
      changeset.each do |op, k, v|
        if persisted_val = persisted_document[k]
          if persisted_val == []
            # work around a bug where mongo won't find a doc
            # using an empty array [] if an index is defined
            # on that field.
            persisted_val = { "$size" => 0 }
          end
          update_selector[k] = persisted_val
        end
      end
      update_selector
    end
end
