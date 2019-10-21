module Contentful
  module EntrySerializer
    def serialize_collection_response(items, includes_hash)
      items.map { |item| serialize_resource_response(item, includes_hash) }
    end

    def serialize_resource_response(item, includes_hash)
      entry = build_fields(item)
      entry = map_embeds(entry, includes_hash) if includes_hash.present?

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

    def to_includes_hash(includes)
      return nil if includes.blank?

      includes_hash = {}

      if includes['Entry'].present?
        includes_hash = reduce_entry_includes(includes_hash, includes['Entry'])
      end

      if includes['Asset'].present?
        includes_hash = reduce_asset_includes(includes_hash, includes['Asset'])
      end

      includes_hash
    end

    def reduce_entry_includes(includes_hash, entry_includes)
      entry_includes.each_with_object includes_hash do |entry, hash|
        kind = entry['sys']['contentType']['sys']['id']
        id = entry['sys']['id']

        hash[kind] = {} if hash[kind].blank?
        hash[kind][id] = build_fields(entry)
      end
    end

    def reduce_asset_includes(includes_hash, asset_includes)
      includes_hash['photo'] = {}

      asset_includes.each_with_object includes_hash do |asset, hash|
        id = asset['sys']['id']
        hash['photo'][id] = build_fields(asset)
      end
    end

    def map_embeds(entry, includes_hash)
      entry.map do |key, value|
        if value.is_a?(Hash) && link_type?(value)
          [key, includes_hash[key.to_s][link_id(value)]]

        elsif value.is_a? Array
          hash_key = key.to_s.singularize
          [key.to_sym, map_embed_collection(value, includes_hash[hash_key])]

        else
          [key, value]

        end
      end.to_h
    end

    def map_embed_collection(collection, collection_hash)
      collection.map do |entry|
        id = link_id(entry)

        collection_hash[id]
      end
    end

    def link_type?(value)
      value.dig('sys', 'type') == 'Link' || value.dig('type') == 'Link'
    end

    def link_id(value)
      value.dig('sys', 'id') || value.dig('id')
    end
  end
end
