import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startDateFormGroup", "startDateTimeFormGroup", "endDateFormGroup", "endDateTimeFormGroup",
    "startDateInput", "startDateTimeInput", "endDateInput", "endDateTimeInput",
    "startDateLabel", "startDateWhenLabel", "startDateTimeLabel", "startDateTimeWhenLabel"
  ]

  connect() {
    this.adjustFormGroups({ target: { value: this.data.get('currentFormat') } });
  }

  adjustFormGroups(event) {
    const offerTimeFormat = event.target.value;

    switch (offerTimeFormat) {
      case "date":
        this.startDateFormGroupTarget.classList.remove("hidden");
        this.startDateInputTarget.disabled = false;
        this.startDateTimeFormGroupTarget.classList.add("hidden");
        this.startDateTimeInputTarget.disabled = true;
        this.endDateFormGroupTarget.classList.add("hidden");
        this.endDateInputTarget.disabled = true;
        this.endDateTimeFormGroupTarget.classList.add("hidden");
        this.endDateTimeInputTarget.disabled = true;

        this.startDateLabelTarget.classList.add("hidden");
        this.startDateWhenLabelTarget.classList.remove("hidden");

        break;
      case "date_and_time":
        this.startDateFormGroupTarget.classList.add("hidden");
        this.startDateInputTarget.disabled = true;
        this.startDateTimeFormGroupTarget.classList.remove("hidden");
        this.startDateTimeInputTarget.disabled = false;
        this.endDateFormGroupTarget.classList.add("hidden");
        this.endDateInputTarget.disabled = true;
        this.endDateTimeFormGroupTarget.classList.add("hidden");
        this.endDateTimeInputTarget.disabled = true;

        this.startDateTimeLabelTarget.classList.add("hidden");
        this.startDateTimeWhenLabelTarget.classList.remove("hidden");

        break;
      case "date_range":
        this.startDateFormGroupTarget.classList.remove("hidden");
        this.startDateInputTarget.disabled = false
        this.startDateTimeFormGroupTarget.classList.add("hidden");
        this.startDateTimeInputTarget.disabled = true;
        this.endDateFormGroupTarget.classList.remove("hidden");
        this.endDateInputTarget.disabled = false;
        this.endDateTimeFormGroupTarget.classList.add("hidden");
        this.endDateTimeInputTarget.disabled = true;

        this.startDateLabelTarget.classList.remove("hidden");
        this.startDateWhenLabelTarget.classList.add("hidden");

        break;
      case "date_and_time_range":
        this.startDateFormGroupTarget.classList.add("hidden");
        this.startDateInputTarget.disabled = true;
        this.startDateTimeFormGroupTarget.classList.remove("hidden");
        this.startDateTimeInputTarget.disabled = false;
        this.endDateFormGroupTarget.classList.add("hidden");
        this.endDateInputTarget.disabled = true;
        this.endDateTimeFormGroupTarget.classList.remove("hidden");
        this.endDateTimeInputTarget.disabled = false;

        this.startDateTimeLabelTarget.classList.remove("hidden");
        this.startDateTimeWhenLabelTarget.classList.add("hidden");

        break;
    }
  }
}
