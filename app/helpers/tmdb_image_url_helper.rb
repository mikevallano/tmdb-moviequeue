# frozen_string_literal: true

module TmdbImageUrlHelper
  # Image Docs: https://developers.themoviedb.org/3/getting-started/images
  # Image configuration: https://developers.themoviedb.org/3/configuration/get-api-configuration

  BASE_URL = "http://image.tmdb.org/t/p/"
  SECURE_BASE_URL = "https://image.tmdb.org/t/p/"
  APPROVED_IMAGE_SIZES = %i[xxsmall xsmall small medium large xlarge xxlarge original]
  APPROVED_IMAGE_TYPES = %i[backdrop logo poster profile still]

  IMAGE_SIZES = {
   backdrop: {
     xxsmall: "w300",
     xsmall: "w300",
     small: "w300",
     medium: "w780",
     large: "w1280",
     xlarge: "w1280",
     xxlarge: "w1280",
     original: "original"
   },
   logo: {
     xxsmall: "w45",
     xsmall: "w92",
     small: "w154",
     medium: "w185",
     large: "w300",
     xlarge: "w500",
     xxlarge: "w500",
     original: "original"
   },
   poster: {
     xxsmall: "w92",
     xsmall: "w92",
     small: "w154",
     medium: "w185",
     large: "w342",
     xlarge: "w500",
     xxlarge: "w780",
     original: "original"
   },
   profile: {
     xxsmall: "w45",
     xsmall: "w45",
     small: "w45",
     medium: "w185",
     large: "h632",
     xlarge: "h632",
     xxlarge: "h632",
     original: "original",
   },
   still: {
     xxsmall: "w92",
     xsmall: "w92",
     small: "w92",
     medium: "w185",
     large: "w300",
     xlarge: "w300",
     xxlarge: "w300",
     original: "original"
   }
  }

  class << self
    def image_url(file_path:, image_type: :backdrop, size: :original)
      raise "image_size must be one of #{APPROVED_IMAGE_SIZES}" unless APPROVED_IMAGE_SIZES.include?(size)
      raise "image_type must be one of #{APPROVED_IMAGE_TYPES}" unless APPROVED_IMAGE_TYPES.include?(image_type)

      image_type_key = image_type.to_sym
      size_key = IMAGE_SIZES[image_type_key][size.to_sym]
      "#{SECURE_BASE_URL}#{size_key}#{file_path}"
    end

    private

  end
end
