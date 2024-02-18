pin 'application', preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@2.2.1/dist/jquery.js"
pin "jquery-ui", to: "https://code.jquery.com/ui/1.12.1/jquery-ui.js"
pin 'autocomplete', preload: true
