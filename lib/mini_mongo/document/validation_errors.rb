module MiniMongo
  module Document
    module ValidationErrors
      extend ActiveSupport::Concern

      def errors
        @errors ||= []
      end

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
        raise ValidationError.new(error_messages) unless valid?
        true
      end

      def error_messages
        errors.map do |field, error|
          [field, I18n.t("#{self.class.name.underscore}.validations.#{field.gsub(/\./, "-")}.#{error}")]
        end
      end

      private
        def clear_errors
          @errors = nil
        end  
    end
  end
end
