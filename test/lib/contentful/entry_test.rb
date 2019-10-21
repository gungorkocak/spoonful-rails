# rubocop:disable all

require 'test_helper'

module ContentfulTests
  class EntryTest < ActiveSupport::TestCase
    def setup
      Contentful.configure do |config|
        config.spaces_url = 'https://spaces-url.com/spaces'
        config.space_id = 'my-space-id'
        config.environment_id = 'my-environment-id'
        config.access_token = 'my-precious'
      end

      @model = Class.new do
        def self.to_model(resource)
          resource
        end
      end

      @entry = Contentful::Entry.new(name: 'my-entry', model: @model)
    end

    test "new sets up name and model" do
      assert @entry.name == 'my-entry'
      assert @entry.model == @model
    end

    test "new sets up conn properly" do
      assert @entry.conn.url_prefix.to_s == 'https://spaces-url.com/spaces/my-space-id/environments/my-environment-id'
      assert @entry.conn.headers['Content-Type'] == 'application/json'
      assert @entry.conn.params['access_token'] == 'my-precious'
      assert @entry.conn.params['content_type'] == 'my-entry'
    end

    test "new raises when given model does not implement class#to_model" do
      model = Class.new

      assert_raises Contentful::ModelNotSerializable do
        entry = Contentful::Entry.new(name: 'my-entry', model: model)
      end
    end
  end
end
