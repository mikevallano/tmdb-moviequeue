require 'rails_helper'

feature "User can visit the search page" do

  scenario "users visits search page successfully" do

    visit('tmdb/search')
    expect(page).to have_content("Search the TMDB Database")

  end

  scenario "users searches for a movie and the API returns results" do

    VCR.use_cassette('tmdb_search') do

      visit('tmdb/search')
      fill_in "Enter Title", with: 'fargo'
      click_button 'Search'
      expect(page).to have_content("1996-04-05")
      expect(page).to have_content("Fargo")

    end

  end

  scenario "users clicks 'more info' and sees more info returned from API" do

    VCR.use_cassette('tmdb_search') do

      visit('tmdb/search')
      fill_in "Enter Title", with: 'fargo'
      click_button 'Search'
      expect(page).to have_content("1996-04-05")
      expect(page).to have_content("Fargo")

    end

    VCR.use_cassette('tmdb_more') do

      click_link('More info', match: :first)
      expect(page).to have_content("Genres: Crime, Drama, Thriller")

    end

  end


end