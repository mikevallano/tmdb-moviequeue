module WaitForAjax
  def wait_for_ajax
    max_time = Capybara::Helpers.monotonic_time + Capybara.default_max_wait_time
    while Capybara::Helpers.monotonic_time < max_time
      finished = finished_all_ajax_requests?
      if finished
        break
      else
        sleep 0.1
      end
    end
    raise 'wait_for_ajax timeout' unless finished
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  rescue
    sleep 0.5
    true
  end
end
