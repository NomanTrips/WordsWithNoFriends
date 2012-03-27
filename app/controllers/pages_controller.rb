class PagesController < ApplicationController

  def wordswithnofriends
    #redirect_to "pages/wordswithnofriends"
    @title = "Words With No Friends"
    if params.size <3 then
      @results = ''
      @letters = ['w','','r','d']
    else
      puts params.size
     @results = WordsDictionary.find_words(params[:word], params[:options])
     @letters = params[:word]
    end
  end

end