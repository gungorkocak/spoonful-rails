require_relative '../../app/lib/contentful'

unless Rails.env.test?
  Contentful.configure do |config|
    config.spaces_url = 'https://cdn.contentful.com/spaces'
    config.space_id = ENV['CONTENTFUL_SPACE_ID']
    config.environment_id = ENV['CONTENTFUL_ENVIRONMENT_ID']
    config.access_token = ENV['CONTENTFUL_ACCESS_TOKEN']
  end
end
