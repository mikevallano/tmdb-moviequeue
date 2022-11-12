class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :movie
  belongs_to :user

  scope :by_user, lambda { |user| where(:user_id => user.id) }

  def self.by_list(list)
    where(:user => List.find(list.id).members)
  end


  def self.create_taggings(tags, movie, user)

    @movie = Movie.find(movie)
    @current_user = user

    @cleantags = tags.split(',').map do |tag|
      tag.strip.gsub(' ','-')
    end

    Tag.first_or_create_tags(@cleantags)

    @cleantags.each do |tag|
      @tag = Tag.find_by_name(tag)
      unless @current_user.taggings.exists?(:tag_id => @tag.id, :movie_id => @movie.id)
        Tagging.create(tag_id: @tag.id, movie_id: @movie.id, user_id: @current_user.id)
      end
    end

  end

end
