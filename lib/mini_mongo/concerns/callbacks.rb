require 'active_model/callbacks'

module MiniMongo
  module Concerns
    module Callbacks
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Callbacks  

        define_model_callbacks :insert, :update, :remove
      end
    end
  end
end
