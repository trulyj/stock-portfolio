class StaticController < ApplicationController
  def show
    @static = render params[:page]
  end

  def transactions
  end
  
end
