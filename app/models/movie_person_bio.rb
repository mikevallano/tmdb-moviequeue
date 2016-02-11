class MoviePersonBio

  def initialize(person_id, name, bio, birthday, profile_path)

    @person_id = person_id
    @name = name
    @bio = bio
    @birthday = birthday
    @profile_path = profile_path

  end #init

  attr_accessor :person_id, :name, :bio, :birthday, :profile_path

  def self.parse_result(result)
    @id = result[:id]
    @name = result[:name]
    @bio = result[:biography]
    @birthday = result[:birthday]
    @profile_path = result[:profile_path]

    MoviePersonBio.new(@id, @name, @bio, @birthday, @profile_path)
  end #parse result

end #class