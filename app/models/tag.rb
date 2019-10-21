class Tag
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :string
  attribute :updated_at, :datetime
  attribute :created_at, :datetime
  attribute :name, :string, default: ''

  def self.to_model(params = {})
    new(params)
  end
end
