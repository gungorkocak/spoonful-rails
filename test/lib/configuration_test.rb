require 'test_helper'

module ContentfulTests
  class ConfigurationTest < ActiveSupport::TestCase
    test "configure sets project wide config" do
      Contentful.configure do |config|
        config.spaces_url = 'https://spaces-url.com/spaces'
        config.space_id = 'my-space-id'
        config.environment_id = 'my-environment-id'
        config.access_token = 'my-precious'
      end

      assert Contentful.configuration.spaces_url == 'https://spaces-url.com/spaces'
      assert Contentful.configuration.space_id == 'my-space-id'
      assert Contentful.configuration.environment_id == 'my-environment-id'
      assert Contentful.configuration.access_token == 'my-precious'
      assert Contentful.configuration.base_url == 'https://spaces-url.com/spaces/my-space-id/environments/my-environment-id'
    end
  end
end
