# frozen_string_literal: true

require 'rails_helper'

describe TmdbImageService do
  describe 'self.image_url' do
    let(:file_path) { '/foo.jpg' }
    it 'returns a secure image url' do
      result = TmdbImageService.image_url(
        file_path: file_path,
        image_type: :poster,
        size: :medium
      )
      expect(result[0..5]).to eq("https:")
    end

    it 'returns a medium poster url by default' do
      result = TmdbImageService.image_url(file_path: file_path)
      expect(result).to eq("https://image.tmdb.org/t/p/w185/foo.jpg")
    end

    it 'handles being passed a string as an argument for image_type' do
      result = TmdbImageService.image_url(file_path: file_path, image_type: 'poster')
      expect(result).to eq("https://image.tmdb.org/t/p/w185/foo.jpg")
    end

    it 'handles being passed a string as an argument for image_type' do
      result = TmdbImageService.image_url(file_path: file_path, size: 'medium')
      expect(result).to eq("https://image.tmdb.org/t/p/w185/foo.jpg")
    end

    it 'raises an error if the supplied image type is invalid' do
      expect do
        TmdbImageService.image_url(
          file_path: file_path,
          image_type: :garbage,
          size: :medium
        )
      end.to raise_error(RuntimeError, 'image_type must be one of [:backdrop, :logo, :poster, :profile, :still]')
    end

    it 'raises an error if the supplied size is invalid' do
      expect do
        TmdbImageService.image_url(
          file_path: file_path,
          image_type: :still,
          size: :garbage
        )
      end.to raise_error(RuntimeError, 'image_size must be one of [:small, :medium, :large, :original]')
    end
  end
end
