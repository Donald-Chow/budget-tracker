import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nested-field"
export default class extends Controller {
  static targets = ["fieldsContainer", "fields"]

  connect() {
  }

  findLastInput() {
    const inputs = this.fieldsContainerTarget.querySelectorAll('input');
    return inputs[inputs.length - 1];
  }

  add(event) {
    event.preventDefault();

    const lastInput = this.findLastInput();
    const lastId = parseInt(lastInput.id.match(/\d+/)[0]);
    const newId = lastId + 1;

    // Remove values from the new fieldset
    const newFieldset = document.createElement('div');
    newFieldset.innerHTML = this.fieldsTarget.outerHTML;
    newFieldset.querySelectorAll('input').forEach(input => {
      input.value = '';
      input.id = input.id.replace(/\d+/, newId);
      input.name = input.name.replace(/\d+/, newId);
      input.classList.remove('border-green-400')
    });
    newFieldset.querySelector('select').classList.remove('border-green-400')
    newFieldset.querySelectorAll('option[selected="selected"]').forEach(option => {
      option.selected = false;
    });
    newFieldset

    const removeButton = document.createElement('div');
    removeButton.className = "rounded-lg m-1 py-1 px-3 bg-red-600 text-white inline-block font-medium cursor-pointer";
    removeButton.dataset.action = "click->nested-field#remove";
    removeButton.textContent = "Remove";

    newFieldset.querySelector('.receipt_items__destroy').replaceWith(removeButton);

    this.fieldsContainerTarget.appendChild(newFieldset);
  }

  remove(event) {
    event.preventDefault();

    event.currentTarget.parentElement.remove();
  }
}
