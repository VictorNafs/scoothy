class SchedulesController < ApplicationController
    def day_schedule
      @date = Date.parse(params[:date])
    end
  end
  
  