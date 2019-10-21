class PhotoFile
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :details

  attribute :url, :string
  attribute :file_name, :string, default: ''
  attribute :content_type, :string, default: ''

  def self.to_model(params = {})
    params[:file_name] = params['fileName']
    params[:content_type] = params['contentType']
    params.except!('fileName', 'contentType')
    new(params)
  end
end
