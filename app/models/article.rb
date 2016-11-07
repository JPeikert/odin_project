class Article < ApplicationRecord

  has_many :comments, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings

  def tag_list
    self.tags.collect do |tag|
      tag.name
    end.join(", ")
  end

  def tag_list=(tags_string)
    tag_names = tags_string.split(",").collect { |tag| tag.strip.downcase }.uniq
    tags = tag_names.collect { |name| Tag.find_or_create_by(name: name) }
    self.tags = tags
  end

end
