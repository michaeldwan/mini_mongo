module MiniMongo
  module Concerns
    module Validation
      extend ActiveSupport::Concern

      def add_error(field, error)
        @errors ||= []
        @errors << [field.to_s, error.to_sym]
      end

      def valid?
        clear_errors
        validate
        @errors.blank?
      end

      def validate
      end

      def validate!
        raise ValidationError.new(self, errors) unless valid?
        true
      end

      def errors
        return [] if @errors.nil?
        @errors.map do |field, error|
          {field: field, code: error}
          # [field, I18n.t("#{self.class.name.underscore}.validations.#{field.gsub(/\./, "-")}.#{error}")]
        end
      end

      private
        def clear_errors
          @errors = nil
        end  
    end
  end
end
