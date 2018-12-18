module Committee
  class SchemaValidator::OpenAPI3::OperationWrapper
    # # @param request_operation [OpenAPIParser::RequestOperation]
    def initialize(request_operation)
      @request_operation = request_operation
    end

    def path_params
      request_operation.path_params
    end

    def original_path
      request_operation.original_path
    end

    def coerce_path_parameter(validator_option)
      options = build_openapi_parser_path_option(validator_option)
      return {} unless options.coerce_value

      request_operation.validate_path_params(options)
    end

    def coerce_request_parameter(params, validator_option)
      options = build_openapi_parser_get_option(validator_option)
      return unless options.coerce_value

      request_operation.validate_request_parameter(params, options)
    end

    def validate_response_params(status_code, content_type, params)
      return request_operation.validate_response_body(status_code, content_type, params)
    rescue OpenAPIParser::OpenAPIError => e
      raise Committee::InvalidRequest.new(e.message)
    end

    def validate_request_params(params, validator_option)
      ret, err = case request_operation.http_method
            when 'get'
              validate_get_request_params(params, validator_option)
            when 'post'
              validate_post_request_params(params, validator_option)
            when 'put'
              validate_post_request_params(params, validator_option)
            when 'patch'
              validate_post_request_params(params, validator_option)
              #when 'delete'
              # TODO: delete validation support
            else
              raise "OpenAPI3 not support #{request_operation.http_method} method"
            end
      raise err if err
      ret
    end

    private

    attr_reader :request_operation

    # @!attribute [r] request_operation
    #   @return [OpenAPIParser::RequestOperation]
    
    # @return [OpenAPIParser::SchemaValidator::Options]
    def build_openapi_parser_path_option(validator_option)
      coerce_value = validator_option.coerce_path_params
      datetime_coerce_class = validator_option.coerce_date_times ? DateTime : nil
      OpenAPIParser::SchemaValidator::Options.new(coerce_value: coerce_value,datetime_coerce_class: datetime_coerce_class)
    end

    # @return [OpenAPIParser::SchemaValidator::Options]
    def build_openapi_parser_post_option(validator_option)
      coerce_value = validator_option.coerce_form_params
      datetime_coerce_class = validator_option.coerce_date_times ? DateTime : nil
      OpenAPIParser::SchemaValidator::Options.new(coerce_value: coerce_value,datetime_coerce_class: datetime_coerce_class)
    end

    # @return [OpenAPIParser::SchemaValidator::Options]
    def build_openapi_parser_get_option(validator_option)
      coerce_value = validator_option.coerce_query_params
      datetime_coerce_class = validator_option.coerce_date_times ? DateTime : nil
      OpenAPIParser::SchemaValidator::Options.new(coerce_value: coerce_value,datetime_coerce_class: datetime_coerce_class)
    end

    def validate_get_request_params(params, validator_option)
      # bad performance because when we coerce value, same check
      request_operation.validate_request_parameter(params, build_openapi_parser_get_option(validator_option))
    rescue OpenAPIParser::OpenAPIError => e
      raise Committee::InvalidRequest.new(e.message)
    end

    def validate_post_request_params(params, validator_option)
      # bad performance because when we coerce value, same check
      # TODO: support other content type
        return request_operation.validate_request_body('application/json', params, build_openapi_parser_post_option(validator_option))
    rescue => e
      raise Committee::InvalidRequest.new(e.message)
    end
  end
end
