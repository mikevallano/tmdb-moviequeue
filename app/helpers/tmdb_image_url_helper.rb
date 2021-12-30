# frozen_string_literal: true

module TmdbImageUrlHelper
  # Image Docs: https://developers.themoviedb.org/3/getting-started/images
  # Image configuration: https://developers.themoviedb.org/3/configuration/get-api-configuration

  BASE_URL = 'https://image.tmdb.org/t/p/'
  APPROVED_IMAGE_TYPES = %i[backdrop logo poster profile still]

  IMAGE_SIZES = {
   backdrop: {
     small: 'w300',
     medium: 'w780',
     large: 'w1280',
     original: 'original'
   },
   logo: {
     xxsmall: 'w45',
     xsmall: 'w92',
     small: 'w154',
     medium: 'w185',
     large: 'w300',
     xlarge: 'w500',
     original: 'original'
   },
   poster: {
     xsmall: 'w92',
     small: 'w154',
     medium: 'w185',
     large: 'w342',
     xlarge: 'w500',
     xxlarge: 'w780',
     original: 'original'
   },
   profile: {
     small: 'w45',
     medium: 'w185',
     large: 'h632',
     original: 'original',
   },
   still: {
     small: 'w92',
     medium: 'w185',
     large: 'w300',
     original: 'original'
   }
  }

  def self.image_url(file_path:, image_type: :poster, size: :medium)
    image_type_key = image_type.to_sym
    raise "image_type must be one of #{APPROVED_IMAGE_TYPES}" unless APPROVED_IMAGE_TYPES.include?(image_type_key)

    available_image_size = IMAGE_SIZES[image_type_key].keys
    size_key = size.to_sym
    raise "image_size must be one of #{available_image_size}" unless available_image_size.include?(size_key)

    formatted_size = IMAGE_SIZES[image_type_key][size_key]
    "#{BASE_URL}#{formatted_size}#{file_path}"
  end
end
