module Committee::Test
  module Methods
    def assert_schema_conform
      @committee_schema ||= begin
        # The preferred option. The user has already parsed a schema elsewhere
        # and we therefore don't have to worry about any performance
        # implications of having to do it for every single test suite.
        if committee_schema
          committee_schema
        else
          schema = schema_contents

          if schema.is_a?(String)
            warn_string_deprecated
          elsif schema.is_a?(Hash)
            warn_hash_deprecated
          end

          if schema.is_a?(String)
            schema = JSON.parse(schema)
          end

          if schema.is_a?(Hash) || schema.is_a?(JsonSchema::Schema)
            driver = Committee::Drivers::HyperSchema.new

            # The driver itself has its own special cases to be able to parse
            # either a hash or JsonSchema::Schema object.
            schema = driver.parse(schema)
          end

          schema
        end
      end

      @committee_router ||= Committee::Router.new(@committee_schema,
        prefix: schema_url_prefix)

      link, _ = @committee_router.find_request_link(last_request)
      unless link
        response = "`#{last_request.request_method} #{last_request.path_info}` undefined in schema."
        raise Committee::InvalidResponse.new(response)
      end

      if validate?(last_response.status)
        data = JSON.parse(last_response.body)
        Committee::ResponseValidator.new(link).call(last_response.status, last_response.headers, data)
      end
    end

    def assert_schema_content_type
      Committee.warn_deprecated("Committee: use of #assert_schema_content_type is deprecated; use #assert_schema_conform instead.")
    end

    # we use this method 3.0 or later
    def committee_options
      Committee.warn_deprecated("Committee: committee 3.0 require overwrite committee options so please use this method.")

      {}
    end

    # Can be overridden with a different driver name for other API definition
    # formats.
    def committee_schema
      schema = committee_options[:schema]
      return schema if schema

      Committee.warn_deprecated("Committee: we'll remove committee_schema method in committee 3.0;" \
        "please use committee_options.")
      nil
    end

    # can be overridden alternatively to #schema_path in case the schema is
    # easier to access as a string
    # blob
    def schema_contents
      Committee.warn_deprecated("Committee: we'll remove schema_contents method in committee 3.0;" \
        "please use committee_options.")
      JSON.parse(File.read(schema_path))
    end

    def schema_path
      Committee.warn_deprecated("Committee: we'll remove schema_path method in committee 3.0;" \
        "please use committee_options.")
      raise "Please override #committee_schema."
    end

    def schema_url_prefix
      prefix = committee_options[:prefix]
      return prefix if prefix

      schema = committee_options[:schema]
      return nil if schema # committee_options set so we don't show warn message

      Committee.warn_deprecated("Committee: we'll remove schema_url_prefix method in committee 3.0;" \
        "please use committee_options.")
      nil
    end

    def warn_hash_deprecated
      Committee.warn_deprecated("Committee: returning a hash from " \
        "#schema_contents and using #schema_path is deprecated; please " \
        "override #committee_schema instead.")
    end

    def warn_string_deprecated
      Committee.warn_deprecated("Committee: returning a string from " \
        "#schema_contents is deprecated; please override #committee_schema " \
        "instead.")
    end

    def validate_response?(status)
      Committee.warn_deprecated("Committee: w'll remove validate_response? method in committee 3.0")

      Committee::ResponseValidator.validate?(status)
    end

    private

      def validate?(status)
        Committee::ResponseValidator.validate?(status)
      end
  end
end
