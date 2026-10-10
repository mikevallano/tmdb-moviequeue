# frozen_string_literal: true

class SuggestionsController < ApplicationController
  MAX_QUERY_LENGTH = 500

  before_action :authenticate_user!
  before_action :restrict_to_admin!

  def index
    @lists = List.by_user(current_user).sort_by { |list| list.name.downcase }
    @list = @lists.find { |list| list.id == params[:list_id].to_i } if params[:list_id].present?
    @query = params[:query].to_s.strip.first(MAX_QUERY_LENGTH).presence
    return unless @list || @query

    @results = MovieSuggestionService.get_suggestions(user: current_user, list: @list, query: @query)
  end
end
