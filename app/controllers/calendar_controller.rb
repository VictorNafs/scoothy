class CalendarController < ApplicationController
    def prev_month
      session[:current_month] = current_month.prev_month
      redirect_to request.referer
    end
  
    def next_month
      session[:current_month] = current_month.next_month
      redirect_to request.referer
    end
  
    private
  
    def current_month
      session[:current_month] ? Date.parse(session[:current_month]) : Date.today
    end
  end
  