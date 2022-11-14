require "json"
require "open-uri"

class GamesController < ApplicationController
  # Creates the random grid of letters
  before_action :set_session

  def new
    @letters = ("a".."z").to_a.sample(10);
  end

  def score
    @answer = params['answer']
    @message = '';
    # Pour chaque lettre du mot donné, on vérifie si elle apparait plus de fois
    # que le nombre de fois qu'elle est dans la grille
    @is_checkable = @answer.split('').all? { |answer_letter|
      params['letters'].downcase.split('').count(answer_letter) >= @answer.downcase.split('').count(answer_letter)
    }

    # Si le mot ne peut être vérifié, on prévient l'utilisateur
    if !@is_checkable
      @message = "Les lettres utilisées ne correspondent pas à celles de la grille"
    else
      # Dans le cas contraire, on check via l'API
      url = "https://wagon-dictionary.herokuapp.com/#{@answer}"
      serialized_query = URI.open(url).read
      @result = JSON.parse(serialized_query)

      # On indique si c'est un mot anglais ou non
      # @result['found'] ? @message = "Congratulations! #{@answer} is a valid English word!" : @message = "Sorry, but #{@answer} does not seem to be a valid English word"
     if @result['found']
      @message = "Congratulations! #{@answer} is a valid English word!"
      @score = @answer.split('').count
      session[:score] += @score
     else
      @message = "Sorry, but #{@answer} does not seem to be a valid English word"
      session[:score] += 0
     end
    end
  end


  private

  def set_session
    session[:score] = 0 unless session[:score]
  end
end
