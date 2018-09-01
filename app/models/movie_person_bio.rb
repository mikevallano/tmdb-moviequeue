class MoviePersonBio


    @person_id = person_id
    @name = name
    @bio = bio
    @profile_path = profile_path

  end #init


  def self.parse_result(result)
    @id = result[:id]
    @name = result[:name]
    @bio = result[:biography].present? ? MoviePersonBio.parse_bio(result[:biography]) : "No birthday available."
    @profile_path = result[:profile_path]

  end #parse result


  def self.parse_bio(bio)
    bio.gsub!(/(From Wikipedia, the free encyclopedia.?)\s+/, '')
    bio.gsub!(/(Description above from).*Wikipedia\s.*\./, "Bio from Wikipedia.")
    bio.gsub(/(?:\n\r?|\r\n?)/, '<br>').html_safe
  end

end #class
