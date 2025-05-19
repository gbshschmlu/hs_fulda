// Variablendeklarationen
// Array zur Speicherung der Farbhistorie (let, da es sich ändern wird)
let colorHistory = [];

class ColorInfo {
    constructor(name, color) {
        this.name = name;
        this.color = color;
        this.timestamp = new Date();
    }
}

// DOM-Referenzen (const, da die Referenzen nicht neu zugewiesen werden)
const previewElem = document.getElementById('preview');
const historyList = document.getElementById('history');
const resetBtn = document.getElementById('resetBtn');
const removeLastBtn = document.getElementById('removeLastBtn');
const showHistoryBtn = document.getElementById('showHistoryBtn');

// Alle Farbbuttons außer dem mit Inline-Event
const colorButtons = document.querySelectorAll('.farb-btn:not([onclick])');

// Event-Listener mit addEventListener für Farbbuttons
colorButtons.forEach(button => {
    button.addEventListener('click', () => {
        const color = button.style.backgroundColor;
        const name = button.innerText;
        updatePreview(color);
        addToHistory(color, name);
    });
});

// Event-Listener für Funktionsbuttons
resetBtn.addEventListener('click', resetAll);
removeLastBtn.addEventListener('click', removeLastColor);
showHistoryBtn.addEventListener('click', displayColorHistory);

// Arrow function für die Aktualisierung der Vorschau
const updatePreview = (color) => {
    previewElem.style.backgroundColor = color;
    previewElem.textContent = '';
    console.log(`Vorschau wurde auf ${color} aktualisiert`);
};

// Klassische Funktionsdefinition zum Hinzufügen zur Historie
function addToHistory(color, name) {
    colorHistory.push(new ColorInfo(color, name));
    console.log(`Neue Länge der Historie: ${colorHistory.length}`);

    // Neues Listenelement erstellen
    const listItem = document.createElement('li');
    listItem.textContent = `${name} (${color}) - ${new Date().toLocaleString()}`;
    listItem.style.backgroundColor = color;
    listItem.classList.add('list-group-item');

    // Dunkler Text für alle Pastellfarben, da sie hell sind
    listItem.style.color = 'var(--gb-dark-anthracite-grey)';

    // Zur Liste hinzufügen
    historyList.appendChild(listItem);
}

// Funktion zum Entfernen der letzten Farbe
function removeLastColor() {
    if (colorHistory.length === 0) {
        console.warn("Die Farbhistorie ist bereits leer!");
        return;
    }

    // Letztes Element aus Array entfernen
    const removedColorInfo = colorHistory.pop();
    console.log(`Entfernte Farbe: ${removedColorInfo.color} mit dem Namen ${removedColorInfo.name} - ${removedColorInfo.timestamp}`);

    // Letztes child aus der Liste entfernen
    historyList.removeChild(historyList.lastChild);

    // Vorschau aktualisieren
    if (colorHistory.length > 0) {
        updatePreview(colorHistory[colorHistory.length - 1]);
    } else {
        resetPreview();
    }
}

// Funktion zum Zurücksetzen
function resetAll() {
    colorHistory = [];
    console.log("Farbhistorie wurde zurückgesetzt");

    historyList.innerHTML = '';

    resetPreview();
}

// Hilfsfunktion zum Zurücksetzen der Vorschau
function resetPreview() {
    previewElem.style.backgroundColor = '';
    previewElem.textContent = 'Vorschau - Wähle eine Farbe';
}

// Funktion zur Anzeige der gesamten Farbhistorie
function displayColorHistory() {
    console.log("-Farbhistorie-");
    for (let i = 0; i < colorHistory.length; i++) {
        console.log(`${i + 1}. Farbe: ${colorHistory[i].color} mit dem Namen ${colorHistory[i].name} - ${colorHistory[i].timestamp}`);
    }
    console.log("-----------------");
}
