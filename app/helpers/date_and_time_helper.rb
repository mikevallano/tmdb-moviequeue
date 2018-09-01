module DateAndTimeHelper
  class << self
    MINUTES_IN_AN_HOUR = 60

    def display_time(minutes)
      return nil if minutes == nil
      return display_time_in_hours(minutes) if minutes % MINUTES_IN_AN_HOUR == 0

      display_time_in_hours_and_minutes(minutes)
    end

    def years_since_date(date)
      today = Date.today
      today.year - date.year - ((today.month > date.month || (today.month == date.month && today.day >= date.day)) ? 0 : 1)
    end

    private

    def display_time_in_hours(minutes)
      "#{minutes / MINUTES_IN_AN_HOUR}hr"
    end

    def display_time_in_hours_and_minutes(minutes)
      "#{minutes / MINUTES_IN_AN_HOUR}h #{minutes % MINUTES_IN_AN_HOUR}m"
    end
  end

end
