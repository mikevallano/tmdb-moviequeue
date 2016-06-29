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
    @bio = result[:biography].present? ? MoviePersonBio.parse_bio(result[:biography]) : "No birthday available."
    @birthday = result[:birthday].present? ? Date.parse(result[:birthday]).stamp("June 9th, 2001") : "No bio available."
    @profile_path = result[:profile_path]

    MoviePersonBio.new(@id, @name, @bio, @birthday, @profile_path)
  end #parse result


  def self.parse_bio(bio)
    bio.gsub!(/(From Wikipedia, the free encyclopedia.?)\s+/, '')
    bio.gsub!(/(Description above from).*Wikipedia\s.*\./, "Bio from Wikipedia.")
    bio.gsub(/(?:\n\r?|\r\n?)/, '<br>').html_safe
  end

end #class
