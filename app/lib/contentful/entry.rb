module Contentful
  class Entry
    include EntrySerializer

    attr_reader :name, :model, :conn

    def initialize(name:, model:)
      @name = name
      @model = model

      unless @model.respond_to?(:to_model)
        raise Contentful::ModelNotSerializable.new(model: @model)
      end

      @conn = build_conn
    end

    def all!
      response = @conn.get('entries')
      body = response.body
      items = body['items']

      return [] if items.blank?

      serialize_collection_response(items)
    end

    def one!(id)
      @conn.params['sys.id'] = id
      response = @conn.get('entries')
      body = response.body
      items = body['items']
      item = items.try(:first)

      return nil if item.blank?

      serialize_resource_response(item)
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
