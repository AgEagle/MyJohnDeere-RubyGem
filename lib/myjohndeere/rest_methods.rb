module MyJohnDeere 
  module RESTMethods
    module ClassMethods
      attr_accessor :resource_base_path
      # If the resource requires a base resource, specify it in the format of:
      # <resource_singular_name_id>: <ID>
      def list(access_token, options = {})
        validate_access_token(access_token)
        options = {count: 10, start: 0, etag: nil}.merge(options)

        base_resources = {}
        options.each do |key, val|
          base_resources[key] = val if key.match(/_id\Z/)
        end

        response = access_token.execute_request(:get, build_resouce_base_path(base_resources), 
          body: {start: options[:start], count: options[:count]},
          etag: options[:etag]
        )
        return_data = response.data["values"]
        return ListObject.new(
          self,
          access_token,
          return_data.collect { |i| self.new(i, access_token) },
          total: response.data["total"],
          options: options.merge(
            etag: response.http_headers[MyJohnDeere::ETAG_HEADER_KEY]
          )
        )
      end

      def retrieve(access_token, id, base_resources={})
        validate_access_token(access_token)
        response = access_token.execute_request(:get, 
          "#{build_resouce_base_path(base_resources)}/#{id}")

        return new(response.data, access_token)
      end

      def build_resouce_base_path(ids)
        return self.resource_base_path if ids.nil? || ids.empty?
        MyJohnDeere.logger.info("Building resource path: #{self.resource_base_path}, with ids: #{ids}")
        return self.resource_base_path % ids
      end

      def validate_access_token(access_token)
        raise ArgumentError.new("The first argument must be an #{AccessToken}") if !access_token.is_a?(AccessToken)
      end
    end
     
    module InstanceMethods
       
    end
     
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end