class Photo
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :file

  attribute :id, :string
  attribute :updated_at, :datetime
  attribute :created_at, :datetime
  attribute :title, :string, default: ''

  def self.to_model(params = {})
    params[:file] = PhotoFile.to_model(params[:file]) if params[:file].present?
    new(params)
  end
end
