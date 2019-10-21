module Contentful
  module EntrySerializer
    def serialize_collection_response(items)
      items.map { |item| serialize_resource_response(item) }
    end

    def serialize_resource_response(item)
      entry = build_fields(item)

      serialize_resource(entry)
    end

    def build_fields(item)
      sys = {
        id: item['sys']['id'],
        created_at: item['sys']['createdAt'],
        updated_at: item['sys']['updatedAt']
      }
      fields = sanitize_item_fields(item['fields'])

      sys.merge(fields)
    end

    def sanitize_item_fields(fields)
      fields.map { |key, value| [key.underscore.to_sym, value] }.to_h
    end

    def serialize_resource(resource)
      @model.send(:to_model, resource)
    end
  end
end
