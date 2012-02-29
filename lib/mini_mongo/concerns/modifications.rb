module MiniMongo
  module Concerns
    module Modifications
      extend ActiveSupport::Concern

      def modify(options = {}, &block)
        snapshot
        changeset = ChangeSet.new

        if block.arity == 1
          yield changeset
        else
          changeset.instance_eval(&block)
        end
        
        return false if changeset.modifiers.empty?

        only_if_current = options.delete(:only_if_current)
        query = self.class.build_update_selector(id, changeset.changes(snapshot_data || MiniMongo::DotHash.new), only_if_current)

        response = collection.update(query, changeset.modifiers, options)
        
        if !response.is_a?(Hash)
          true
        elsif response["err"].blank? && response["n"] == 1
          true
        else
          raise MiniMongo::ModifierUpdateError, response.inspect
        end
      end
      alias :mod :modify

      def modify!(options = {}, &block)
        mod(options.merge(safe: true), &block)
      end
      alias :mod! :modify!

      class ChangeSet
        attr_reader :modifiers

        def initialize
          @modifiers = Hash.new { |h,k| h[k] = {} }
        end

        def inc(key, value = 1)
          @modifiers[:$inc][key.to_s] = value
        end

        def set(key, value)
          @modifiers[:$set][key.to_s] = value
        end

        def unset(*fields)
          Array.wrap(fields).each do |field|
            @modifiers[:$unset][field.to_s] = 1
          end
        end

        def push(key, value)
          @modifiers[:$push][key.to_s] = value
        end

        def push_all(key, *value)
          @modifiers[:$pushAll][key.to_s] = Array.wrap(value)
        end

        def add_to_set(key, value, each = false)
          if value.respond_to?(:each) && each
            value = {:$each => value}
          end
          @modifiers[:$addToSet][key.to_s] = value
        end

        def pop(key, value)
          @modifiers[:$pop][key.to_s] = value
        end

        def pull(key, value)
          @modifiers[:$pull][key.to_s] = value
        end

        def pull_all(key, *value)
          @modifiers[:$pullAll][key.to_s] = Array.wrap(value)
        end

        def rename(key, new_key_name)
          @modifiers[:$rename][key.to_s] = new_key_name.to_s
        end

        def bit(key, value)
          @modifiers[:$bit][key.to_s] = value
        end

        def changes(original)
          changes = {}
          modified_keys.each do |key|
            changes[key] = [original[key], true]
          end
          changes
        end

        def modified_keys
          @modifiers.map { |key, mods| mods.keys }.flatten.uniq
        end
      end

      module ClassMethods
        def modify(query = {}, options = {}, &block)
          changeset = ChangeSet.new

          if block.arity == 1
            yield changeset
          else
            changeset.instance_eval(&block)
          end

          return false if changeset.modifiers.empty?

          response = collection.update(query, changeset.modifiers, options)

          if !response.is_a?(Hash)
            true
          elsif response["n"] >= 1
            response["n"]
          else
            raise MiniMongo::ModifierUpdateError, response.inspect
          end
        end
        alias :mod :modify

        def modify!(query = {}, options = {}, &block)
          mod(query, options.merge(safe: true), &block)
        end
        alias :mod! :modify!
      end
    end
  end
end
