// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
window.$ = window.jQuery = require('jquery');
require("raty-js")


Rails.start()
ActiveStorage.start()

window.Noty = require("noty")
window.Dropzone = require("dropzone")
window.BulmaCarousel = require("bulma-extensions/bulma-carousel/dist/js/bulma-carousel")
window.Calendar = require("@fullcalendar/core").Calendar;
window.DayGridPlugin = require("@fullcalendar/daygrid").default;
window.ListPlugin = require("@fullcalendar/list").default;

require("trix")
require("@rails/actiontext")