require 'active_model/serializers/json'
require 'active_model/serializers/xml'

module MiniMongo
  module Concerns
    module Serialization
      extend ActiveSupport::Concern

      include ::ActiveModel::Serializers::JSON
      include ::ActiveModel::Serializers::Xml

      included do             
        self.include_root_in_json = false
      end

      def serializable_hash(options = nil)
        to_hash
      end
    end
  end
end
