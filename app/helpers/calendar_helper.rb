module CalendarHelper
    def dates_by_weekday(dates)
      dates.group_by { |date| date.wday }
    end
  
    def empty_weekdays_array
      Array.new(7) { [] }
    end
  
    def shifted_day_names
      day_names = I18n.t("date.abbr_day_names")
      day_names.rotate(1)
    end

    def current_month
        session[:current_month] ? Date.parse(session[:current_month]) : Date.today
    end
  end
  