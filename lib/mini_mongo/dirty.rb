module MiniMongo::Dirty
  def dirty?
    (!persisted? && !removed?) || changes.present?
  end

  def changes
    @changes ||= begin
      persisted_hash = (self.snapshot_data || MiniMongo::DotHash.new).to_key_value
      current_hash = self.document.to_key_value

      changes = {}

      (persisted_hash.keys - current_hash.keys).each do |key|
        changes[key] = [persisted_hash[key], nil]
      end

      (current_hash.keys - persisted_hash.keys).each do |key|
        changes[key] = [nil, current_hash[key]]
      end

      (persisted_hash.keys & current_hash.keys).each do |key|
        old_value = persisted_hash[key]
        new_value = current_hash[key]
        changes[key] = [old_value, new_value] if old_value != new_value
      end

      changes
    end
  end

  # protected
    def snapshot
      @changes = nil
      return if @snapshot
      @snapshot = Marshal.dump(self.document.dup)
      true
    end

    def snapshot_data
      @snapshot_data ||= begin
        snapshot if persisted? && @snapshot.nil?
        Marshal.load(@snapshot) if @snapshot
      end
    end

    def clear_snapshot
      @snapshot = @snapshot_data = @changes = nil
    end
end
