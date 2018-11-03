module Committee
  class SchemaValidator::OpenAPI3::Router
    def initialize(schema, validator_option)
      @schema = schema
      @prefix = validator_option.prefix
      @validator_option = validator_option
    end

    def includes_request?(request)
      return true unless @prefix
      #path = request.path
      #path.start_with?(@prefix)
    end

    def build_schema_validator(request)
      Committee::SchemaValidator::OpenAPI3.new(self, request, @validator_option)
    end

    def path_object(request)
      path = request.path
      @schema.path_object(path)
    end
  end
end
