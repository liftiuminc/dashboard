class MoversController < ApplicationController
  def index
    @movers = Movers.all
  end
end
