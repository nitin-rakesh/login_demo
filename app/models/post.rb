class Post < ActiveRecord::Base

  belongs_to :user
  validates_presence_of :post_description, :message => "Please enter description"
  
end
