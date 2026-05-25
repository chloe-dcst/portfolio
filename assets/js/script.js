/* assets/js/script.js */

function ouvrirPopup() {
    const popup = document.getElementById("popupMail");
    if(popup) popup.style.display = "flex";
}

function fermerPopup() {
    const popup = document.getElementById("popupMail");
    const msg = document.getElementById("msgConfirmation");
    if(popup) popup.style.display = "none";
    if(msg) msg.style.display = "none";
}

function copierAdresse() {
    const emailElement = document.getElementById("monEmail");
    const msg = document.getElementById("msgConfirmation");
    
    if(emailElement) {
        const email = emailElement.innerText;
        navigator.clipboard.writeText(email).then(() => {
            if(msg) msg.style.display = "block";
            setTimeout(fermerPopup, 1500);
        });
    }
}

/* Fonctions pour le modal Bilan */
function afficherBilan(annee) {
    const details = document.querySelectorAll('.bilan-detail');
    details.forEach(detail => detail.style.display = 'none');
    document.getElementById(annee).style.display = 'block';
    document.getElementById('bilanModal').style.display = 'flex';
}

function fermerBilan() {
    document.getElementById('bilanModal').style.display = 'none';
}