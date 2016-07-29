class Picture < ActiveRecord::Base
	
	belongs_to :pictureable, :polymorphic => true
  has_attached_file :image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>", 
                                         :winner => "640x320#"},
                                         }.merge(POST_IMAGE_PATH)
	validates_attachment_size :image, :less_than => 2.megabyte
  do_not_validate_attachment_file_type :image
  validates_attachment_content_type :image, 
                                    :content_type => /^image\/(png|jpeg)/,
                                    :message => 'only (png/jpeg) images'
end
