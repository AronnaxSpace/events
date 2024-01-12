import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startDateFormGroup", "startDateTimeFormGroup", "endDateFormGroup", "endDateTimeFormGroup",
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
        this.startDateTimeFormGroupTarget.classList.add("hidden");
        this.endDateFormGroupTarget.classList.add("hidden");
        this.endDateTimeFormGroupTarget.classList.add("hidden");

        this.startDateLabelTarget.classList.add("hidden");
        this.startDateWhenLabelTarget.classList.remove("hidden");

        break;
      case "date_and_time":
        this.startDateFormGroupTarget.classList.add("hidden");
        this.startDateTimeFormGroupTarget.classList.remove("hidden");
        this.endDateFormGroupTarget.classList.add("hidden");
        this.endDateTimeFormGroupTarget.classList.add("hidden");

        this.startDateTimeLabelTarget.classList.add("hidden");
        this.startDateTimeWhenLabelTarget.classList.remove("hidden");

        break;
      case "date_range":
        this.startDateFormGroupTarget.classList.remove("hidden");
        this.startDateTimeFormGroupTarget.classList.add("hidden");
        this.endDateFormGroupTarget.classList.remove("hidden");
        this.endDateTimeFormGroupTarget.classList.add("hidden");

        this.startDateLabelTarget.classList.remove("hidden");
        this.startDateWhenLabelTarget.classList.add("hidden");

        break;
      case "date_and_time_range":
        this.startDateFormGroupTarget.classList.add("hidden");
        this.startDateTimeFormGroupTarget.classList.remove("hidden");
        this.endDateFormGroupTarget.classList.add("hidden");
        this.endDateTimeFormGroupTarget.classList.remove("hidden");

        this.startDateTimeLabelTarget.classList.remove("hidden");
        this.startDateTimeWhenLabelTarget.classList.add("hidden");

        break;
    }
  }
}
