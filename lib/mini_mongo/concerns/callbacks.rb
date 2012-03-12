require 'active_model/callbacks'

module MiniMongo
  module Concerns
    module Callbacks
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Callbacks  

        define_model_callbacks :insert, :update, :save, :remove, :only => [:after, :before]
        define_model_callbacks :initialize, :only => [:after]
      end
    end
  end
end
