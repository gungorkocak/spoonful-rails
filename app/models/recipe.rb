class Recipe
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :photo, :chef, :tags

  attribute :id, :string
  attribute :updated_at, :datetime
  attribute :created_at, :datetime
  attribute :title, :string, default: ''
  attribute :description, :string, default: ''

  def self.all!
    entry = Contentful::Entry.new(name: 'recipe', model: Recipe)

    entry
      .select([:title, :photo])
      .includes([:photo])
      .all!
  end

  def self.one!(id)
    entry = Contentful::Entry.new(name: 'recipe', model: Recipe)

    entry
      .select([:title, :photo, :description, :chef, :tags])
      .includes([:photo, :chef, :tags])
      .one!(id)
  end

  def self.to_model(params = {})
    params[:photo] = Photo.to_model(params[:photo]) if params[:photo].present?
    params[:chef] = Chef.to_model(params[:chef]) if params[:chef].present?

    if params[:tags].present?
      params[:tags] = params[:tags].map { |t| Tag.to_model(t) }
    end

    new(params)
  end
end
