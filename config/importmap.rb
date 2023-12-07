pin 'application', preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@2.2.1/dist/jquery.js"
pin "jquery-autocomplete", to: "https://cdn.jsdelivr.net/npm/jquery-autocomplete@1.2.8/jquery.autocomplete.js"
pin 'bootstrap', to: 'https://maxcdn.bootstrapcdn.com/bootstrap/3.0.2/js/bootstrap.min.js'