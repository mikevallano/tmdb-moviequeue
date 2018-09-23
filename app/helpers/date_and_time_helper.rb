module DateAndTimeHelper
  class << self
    MINUTES_IN_AN_HOUR = 60

    def display_time(minutes)
      return nil if minutes.blank?

      full_hour?(minutes) ? display_time_in_hours(minutes) : display_time_in_hours_and_minutes(minutes)
    end

    def years_between_dates(starting_date:, ending_date:)
      ending_date.year - starting_date.year - (date_occurred_yet_for_year?(starting_date, ending_date) ? 0 : 1)
    end

    def years_since_date(date)
      today = Time.zone.today
      today.year - date.year - (date_occurred_yet_for_year?(date, today) ? 0 : 1)
    end

    private

    def date_occurred_yet_for_year?(starting_date, ending_date)
      ending_date.month > starting_date.month || (ending_date.month == starting_date.month && ending_date.day >= starting_date.day)
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
