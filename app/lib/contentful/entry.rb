module Contentful
  class Entry
    attr_reader :name, :model, :conn

    def initialize(name:, model:)
      @name = name
      @model = model

      unless @model.respond_to?(:to_model)
        raise Contentful::ModelNotSerializable.new(model: @model)
      end

      @conn = build_conn
    end

    private

    def build_conn
      Faraday.new conn_options do |conn|
        conn.use Faraday::HttpCache, store: Rails.cache, logger: Rails.logger
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def conn_options
      {
        url: Contentful.configuration.base_url,
        params: {
          'access_token' => Contentful.configuration.access_token,
          'content_type' => @name,
          'include' => 0
        },
        headers: { 'Content-Type' => 'application/json' }
      }
    end
  end
end
