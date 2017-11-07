require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    alphabet = ("a".."z").to_a
    grid = []
    10.times do |i|
      grid << alphabet.sample
    end
    @letters = grid
  end

  def score
    @answer = params[:word_guess]
    @letters = params[:generated_grid].split(" ")
    @start_time = params[:start_time].to_i
    @end_time = Time.now.to_i

    @result = run_game(@answer, @letters, @start_time, @end_time)
  end

  def in_grid_ness?(attempt, grid)
    word_array = attempt.downcase.chars
    in_grid_ness = word_array.all? do |char|
      grid.include?(char) && word_array.count(char) <= grid.count(char)
    end
    return in_grid_ness
  end

  def in_dictionary?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    # parsing
    englishness = open(url).read
    englishness_hash = JSON.parse(englishness)
    return englishness_hash
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    result = { score: 0.to_i, time: end_time - start_time, message: "" }

    if in_dictionary?(attempt)["found"] == false
      result[:message] = "That is not an English word, you fool!"
    elsif in_grid_ness?(attempt, grid) == false
      result[:message] = "Not in the grid!"
    else
      result[:message] = "Great work, well done with #{attempt}"
      result[:score] = (attempt.upcase.chars.length.to_i * 100 / (end_time - start_time).to_i)
    end

    return result
  end

end
