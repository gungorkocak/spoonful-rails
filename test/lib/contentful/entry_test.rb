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

    test "includes adds conn include param" do
      next_entry = @entry.includes([:chef, :photo])

      assert next_entry.embeds == [:chef, :photo]
      assert next_entry.conn.params['include'] == 1
    end

    test "select adds conn select param" do
      next_entry = @entry.select([:title, :desc])

      assert next_entry.selection_fields == [:title, :desc]
      assert next_entry.conn.params['select'] == 'sys,fields.title,fields.desc'


      next_entry = next_entry.select([:photo])

      assert next_entry.selection_fields == [:photo]
      assert next_entry.conn.params['select'] == 'sys,fields.photo'


      next_entry = next_entry.select([])

      assert next_entry.selection_fields == []
      refute next_entry.conn.params['select']
    end
  end

  class EntrySerializationTest < ActiveSupport::TestCase
    class SerializableMockModel
      def self.to_model(params = {})
        OpenStruct.new(params)
      end
    end

    def setup
      Contentful.configure do |config|
        config.spaces_url = 'https://cdn.contentful.com/spaces'
        config.space_id = ENV['CONTENTFUL_SPACE_ID']
        config.environment_id = ENV['CONTENTFUL_ENVIRONMENT_ID']
        config.access_token = ENV['CONTENTFUL_ACCESS_TOKEN']
      end

      @model = SerializableMockModel
      @entry = Contentful::Entry.new name: 'recipe', model: @model

      VCR.insert_cassette self.method_name
    end

    def teardown
      VCR.eject_cassette self.method_name
    end

    test "all serializes response to correct model" do
      items = @entry.all!

      items[0..10].each do |item|
        assert item.id
        assert item.updated_at
        assert item.created_at
        assert item.title
        assert item.description
        assert item.calories
      end
    end

    test "all includes embedded fields" do
      items =
        @entry
          .select([:title, :photo, :chef, :tags])
          .includes([:photo, :chef, :tags])
          .all!

      items[0..10].each do |item|
        assert item.id
        assert item.created_at
        assert item.updated_at
        assert item.title
        assert item.photo[:id]
        assert item.photo[:title]
        assert item.photo[:file]['url']

        if item.chef.present?
          assert item.chef[:id]
          assert item.chef[:name]
        end

        if item.tags.present?
          item.tags.each do |tag|
            assert tag[:id]
            assert tag[:name]
          end
        end
      end
    end

    test "all gets only selected fields" do
      items =
        @entry
          .select([:title, :photo])
          .includes([:photo])
          .all!

      items[0..10].each do |item|
        assert item.id
        assert item.created_at
        assert item.updated_at
        assert item.title
        assert item.photo[:id]
        assert item.photo[:title]
        assert item.photo[:file]['url']
        refute item.description
        refute item.chef
        refute item.tags
      end
    end

    test "one serializes response to correct model" do
      item = @entry.one!('2E8bc3VcJmA8OgmQsageas')

      assert item.id
      assert item.updated_at
      assert item.created_at
      assert item.title
      assert item.description
      assert item.calories
    end

    test "one includes embedded fields" do
      item =
        @entry
          .select([:title, :photo, :chef, :tags])
          .includes([:photo, :chef, :tags])
          .one!('2E8bc3VcJmA8OgmQsageas')

      assert item.id
      assert item.created_at
      assert item.updated_at
      assert item.title
      assert item.photo[:id]
      assert item.photo[:title]
      assert item.photo[:file]['url']

      if item.chef.present?
        assert item.chef[:id]
        assert item.chef[:name]
      end

      if item.tags.present?
        item.tags.each do |tag|
          assert tag[:id]
          assert tag[:name]
        end
      end
    end

    test "one gets only selected fields" do
      item =
        @entry
          .select([:title, :photo])
          .includes([:photo])
          .one!('2E8bc3VcJmA8OgmQsageas')

      assert item.id
      assert item.created_at
      assert item.updated_at
      assert item.title
      assert item.photo[:id]
      assert item.photo[:title]
      assert item.photo[:file]['url']
      refute item.description
      refute item.chef
      refute item.tags
    end
  end

  class EntryNetworkTest < ActiveSupport::TestCase
    class SerializableMockModel
      def self.to_model(params = {})
        OpenStruct.new(params)
      end
    end

    def setup
      VCR.turn_off!
    end

    def teardown
      VCR.turn_on!
    end

    test "all raises NotFound when url is wrong" do
      Contentful.configure do |config|
        config.spaces_url = 'https://cdn.contentful.com/spaces'
        config.space_id = 'wrong-space-id'
        config.environment_id = ENV['CONTENTFUL_ENVIRONMENT_ID']
        config.access_token = ENV['CONTENTFUL_ACCESS_TOKEN']
      end

      @model = SerializableMockModel
      @entry = Contentful::Entry.new name: 'recipe', model: @model

      @entry.all!
      assert false

    rescue Contentful::EntryNotFound
      assert true
    end

    test "all raises NotFound when recipe is wrong" do
      Contentful.configure do |config|
        config.spaces_url = 'https://cdn.contentful.com/spaces'
        config.space_id = ENV['CONTENTFUL_SPACE_ID']
        config.environment_id = ENV['CONTENTFUL_ENVIRONMENT_ID']
        config.access_token = ENV['CONTENTFUL_ACCESS_TOKEN']
      end

      @model = SerializableMockModel
      @entry = Contentful::Entry.new name: 'wrong-recipe', model: @model

      @entry.all!
      assert false

    rescue Contentful::BadRequest
      assert true
    end

    test "one raises NotFound when url is wrong" do
      Contentful.configure do |config|
        config.spaces_url = 'https://cdn.contentful.com/spaces'
        config.space_id = 'wrong-space-id'
        config.environment_id = ENV['CONTENTFUL_ENVIRONMENT_ID']
        config.access_token = ENV['CONTENTFUL_ACCESS_TOKEN']
      end

      @model = SerializableMockModel
      @entry = Contentful::Entry.new name: 'recipe', model: @model

      @entry.one!('2E8bc3VcJmA8OgmQsageas')
      assert false

    rescue Contentful::EntryNotFound
      assert true
    end

    test "one raises NotFound when recipe is wrong" do
      Contentful.configure do |config|
        config.spaces_url = 'https://cdn.contentful.com/spaces'
        config.space_id = ENV['CONTENTFUL_SPACE_ID']
        config.environment_id = ENV['CONTENTFUL_ENVIRONMENT_ID']
        config.access_token = ENV['CONTENTFUL_ACCESS_TOKEN']
      end

      @model = SerializableMockModel
      @entry = Contentful::Entry.new name: 'wrong-recipe', model: @model

      @entry.one!('2E8bc3VcJmA8OgmQsageas')
      assert false

    rescue Contentful::BadRequest
      assert true
    end
  end
end
