module Contentful
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
    self.configuration.update_base_url
  end

  class Configuration
    attr_accessor :spaces_url, :space_id, :environment_id, :access_token
    attr_reader :base_url

    def update_base_url
      @base_url = "#{@spaces_url}/#{@space_id}/environments/#{@environment_id}"
    end
  end
end
