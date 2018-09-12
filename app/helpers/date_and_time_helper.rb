module DateAndTimeHelper
  class << self
    MINUTES_IN_AN_HOUR = 60

    def display_time(minutes)
      return nil if minutes.blank?

      full_hour?(minutes) ? display_time_in_hours(minutes) : display_time_in_hours_and_minutes(minutes)
    end

    def years_since_date(date)
      today = Time.zone.today
      today.year - date.year - (date_occurred_yet_this_year?(date, today) ? 0 : 1)
    end

    private

    def date_occurred_yet_this_year?(date, today)
      today.month > date.month || (today.month == date.month && today.day >= date.day)
    end

    def full_hour?(minutes)
      (minutes % MINUTES_IN_AN_HOUR).zero?
    end

    def display_time_in_hours(minutes)
      "#{minutes / MINUTES_IN_AN_HOUR}hr"
    end

    def display_time_in_hours_and_minutes(minutes)
      "#{minutes / MINUTES_IN_AN_HOUR}h #{minutes % MINUTES_IN_AN_HOUR}m"
    end
  end
end
