import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source" ]

  copy() {
    const textToCopy = this.sourceTarget.innerText;
    navigator.clipboard.writeText(textToCopy)
      .then(() => {
        alert("URL copiada al portapapeles: " + textToCopy);
      })
      .catch(err => {
        console.error("Error al copiar al portapapeles: ", err);
        alert("No se pudo copiar la URL.");
      });
  }
}