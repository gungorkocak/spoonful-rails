module Contentful
  class Entry
    include EntrySerializer

    attr_reader :name, :model, :conn, :embeds, :selection_fields

    def initialize(name:, model:)
      @name = name
      @model = model

      unless @model.respond_to?(:to_model)
        raise Contentful::ModelNotSerializable.new(model: @model)
      end

      @conn = build_conn
    end

    def includes(embeds = [])
      @embeds = embeds
      @conn.params['include'] = @embeds.present? ? 1 : 0

      self
    end

    def select(fields = [])
      @selection_fields = fields

      if fields.present?
        mapped_fields = fields.map { |f| "fields.#{f}" }
        @conn.params['select'] = (['sys'] + mapped_fields).join(',')
      else
        @conn.params.except!('select')
      end

      self
    end

    def all!
      response = @conn.get('entries')
      body = response.body
      items = body['items']

      return [] if items.blank?

      includes = body['includes']
      includes_hash = to_includes_hash(includes)

      serialize_collection_response(items, includes_hash)
    end

    def one!(id)
      @conn.params['sys.id'] = id
      response = @conn.get('entries')
      body = response.body
      items = body['items']
      item = items.try(:first)

      return nil if item.blank?

      includes = body['includes']
      includes_hash = to_includes_hash(includes)

      serialize_resource_response(item, includes_hash)
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
