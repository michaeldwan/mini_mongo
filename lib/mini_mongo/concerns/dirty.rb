module MiniMongo
  module Concerns
    module Dirty
      def dirty?
        (!persisted? && !removed?) || changes.present?
      end

      def changes
        @changes ||= begin
          persisted_hash = (self.snapshot_data || MiniMongo::DotHash.new).to_key_value
          current_hash = self.document.to_key_value

          changes = {}

          (persisted_hash.keys + current_hash.keys).uniq.sort_by { |key| key.length }.each do |key|
            next if changes.keys.include?(key[0...(key.rindex('.') || -1)])

            old_value = persisted_hash[key]
            new_value = current_hash[key]
            next if old_value == new_value
            next if old_value.is_a?(Hash) && new_value.is_a?(Hash)
            changes[key] = [old_value, new_value]
          end

          changes
        end
      end

      # protected
        def snapshot
          @changes = nil
          return if @snapshot || new?
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
  end
end
