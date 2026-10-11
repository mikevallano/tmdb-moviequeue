require 'rails_helper'

RSpec.feature "Suggestions feature spec", type: :feature, feature: :true do
  let(:admin) { FactoryBot.create(:user, admin: true) }
  let!(:list) { FactoryBot.create(:list, owner: admin, name: 'Christmas') }

  scenario "admins see a loading message in place of the form while suggestions load", js: true do
    allow(MovieSuggestionService).to receive(:get_suggestions) do
      sleep 1.5
      OpenStruct.new(movies: [], not_found_message: 'No suggestions this time.')
    end

    sign_in_user(admin)
    visit movie_suggestions_path
    select 'Christmas', from: 'list_id'
    fill_in 'query', with: 'but lighter'
    click_button 'Get suggestions'

    expect(page).to have_content('Finding movies like Christmas: "but lighter"')
    expect(page).not_to have_button('Get suggestions')

    expect(page).to have_content('No suggestions this time.', wait: 5)
    expect(page).not_to have_content('Finding movies like')

    # The form collapses into a summary of what was asked
    expect(page).to have_content('Like Christmas · "but lighter"')
    expect(page).not_to have_button('Get suggestions')

    find('summary', text: 'Get more suggestions').click
    expect(page).to have_button('Get suggestions')
    expect(page).to have_select('list_id', selected: 'Christmas')
    expect(page).to have_field('query', with: 'but lighter')
  end
end
