// Quiz de compréhension à la fin d'un document (banque de questions de _data/quiz/<document>.yml,
// placée dans la page par _layouts/default.html). À chaque essai, « nombre » questions (10 par
// défaut) sont tirées au hasard dans la banque, d'abord parmi celles que le poste n'a pas encore
// vues; l'ordre des choix multiples est aussi mélangé. Le résultat et les bonnes réponses
// s'affichent à la fin. Le résultat est gardé dans le navigateur du poste (localStorage, clé
// « ve2cuy-quiz:<chemin de la page> ») : la page d'accueil le lit pour marquer la vignette.
(() => {
  const donnees = document.getElementById("quiz-donnees");
  const zone = document.getElementById("quiz");
  if (!donnees || !zone) return;
  let quiz;
  try { quiz = JSON.parse(donnees.textContent); } catch (e) { return; }
  const banque = (quiz.questions || []).filter((q) => q && q.question);
  if (!banque.length) return;
  const nombre = Math.min(banque.length, Math.max(1, Number(quiz.nombre) || 10));

  const chemin = location.pathname.replace(/\.html$/, "").replace(/\/$/, "/index");
  const cle = "ve2cuy-quiz:" + chemin;
  const cleVues = "ve2cuy-quiz-vues:" + chemin;
  const lire = (k) => { try { return JSON.parse(localStorage.getItem(k)) || null; } catch (e) { return null; } };
  const ecrire = (k, v) => { try { localStorage.setItem(k, JSON.stringify(v)); } catch (e) {} };

  const el = (tag, cls, texte) => { const e = document.createElement(tag); if (cls) e.className = cls; if (texte != null) e.textContent = texte; return e; };
  const dateCourte = (iso) => { try { return new Date(iso).toLocaleDateString("fr-CA", { day: "numeric", month: "long", year: "numeric" }); } catch (e) { return iso; } };
  const melanger = (t) => { const a = [...t]; for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; };
  const estVf = (q) => q.type === "vf" || !q.choix;

  // Tirage : questions jamais vues sur ce poste d'abord (par leur texte, pour survivre aux
  // modifications de la banque); quand toutes ont été vues, on recommence le cycle.
  function tirer() {
    let vues = new Set((lire(cleVues) || []).filter((t) => banque.some((q) => q.question === t)));
    let neuves = banque.filter((q) => !vues.has(q.question));
    let choisies = melanger(neuves).slice(0, nombre);
    if (choisies.length < nombre) {
      const pris = new Set(choisies.map((q) => q.question));
      choisies = choisies.concat(melanger(banque.filter((q) => !pris.has(q.question))).slice(0, nombre - choisies.length));
      vues = new Set();
    }
    choisies.forEach((q) => vues.add(q.question));
    ecrire(cleVues, [...vues]);
    // Choix : « vrai »/« faux », ou la liste « choix » (mélangée) dont « reponse » est le numéro du bon (à partir de 1)
    return choisies.map((q) => {
      if (estVf(q)) return { q, choix: ["Vrai", "Faux"], bon: String(q.reponse).toLowerCase().startsWith("v") || q.reponse === true ? 0 : 1, vf: true };
      const ordre = melanger(q.choix.map((c, i) => i));
      return { q, choix: ordre.map((i) => String(q.choix[i])), bon: ordre.indexOf(Number(q.reponse) - 1), vf: false };
    });
  }

  const titre = el("h2", null, quiz.titre || "Quiz de compréhension");
  const intro = el("p", "quiz-intro");
  intro.textContent = `${nombre} questions tirées au hasard dans une banque de ${banque.length}` +
    " (vrai ou faux et choix multiple). Répondez à toutes les questions : votre résultat et les bonnes réponses s'affichent à la fin." +
    (banque.length > nombre ? " Recommencez le quiz pour avoir d'autres questions." : "");
  const deja = el("p", "quiz-deja");
  const resultat = el("div", "quiz-resultat");
  resultat.setAttribute("role", "status");
  resultat.tabIndex = -1;
  resultat.hidden = true;
  const form = el("form", "quiz-form");
  form.noValidate = true;
  const questionsZone = el("div", "quiz-questions");
  const pied = el("div", "quiz-pied");
  const compte = el("span", "quiz-compte");
  const envoyer = el("button", "quiz-bouton", "Voir mon résultat");
  envoyer.type = "submit";
  const recommencer = el("button", "quiz-bouton secondaire", "Recommencer avec d'autres questions");
  recommencer.type = "button";
  pied.append(compte, envoyer, recommencer);
  form.append(questionsZone, pied);

  let blocs = [];
  function nouvelEssai() {
    blocs = tirer().map((t, i) => {
      const fs = el("fieldset", "quiz-q");
      const lg = el("legend");
      lg.append(el("span", "quiz-num", `Question ${i + 1} / ${nombre}`), el("span", "quiz-texte", t.q.question));
      fs.append(lg);
      const opts = el("div", "quiz-choix" + (t.vf ? " vf" : ""));
      t.choix.forEach((c, j) => {
        const lab = el("label", "quiz-option");
        const inp = el("input");
        inp.type = "radio"; inp.name = "q" + i; inp.value = String(j);
        lab.append(inp, el("span", null, c));
        opts.append(lab);
      });
      const corr = el("p", "quiz-correction");
      corr.hidden = true;
      fs.append(opts, corr);
      return { ...t, fs, corr };
    });
    questionsZone.replaceChildren(...blocs.map((b) => b.fs));
    resultat.hidden = true;
    envoyer.hidden = false;
    compte.hidden = false;
    recommencer.hidden = true;
    majCompte();
    majDeja();
  }

  const repondues = () => blocs.filter((b, i) => form.querySelector(`input[name="q${i}"]:checked`)).length;
  function majCompte() {
    const n = repondues();
    compte.textContent = `${n} / ${nombre} répondues`;
    envoyer.disabled = n < nombre;
  }
  function majDeja() {
    const r = lire(cle);
    deja.hidden = !r;
    if (r) deja.textContent = `Quiz déjà fait sur ce poste le ${dateCourte(r.date)} : ${r.score} / ${r.total}` +
      (r.meilleur != null && r.meilleur !== r.score ? ` (meilleur résultat : ${r.meilleur} / ${r.total})` : "") +
      (r.essais > 1 ? ` · ${r.essais} essais` : "") + ".";
  }

  form.addEventListener("change", majCompte);
  form.addEventListener("submit", (ev) => {
    ev.preventDefault();
    if (repondues() < nombre) return;
    let score = 0;
    blocs.forEach(({ q, choix, bon, fs, corr }, i) => {
      const choisi = Number(form.querySelector(`input[name="q${i}"]:checked`).value);
      const juste = choisi === bon;
      if (juste) score++;
      fs.classList.add(juste ? "juste" : "faux");
      fs.querySelectorAll(".quiz-option").forEach((lab, j) => {
        if (j === bon) lab.classList.add("bonne");
        else if (j === choisi) lab.classList.add("mauvaise");
      });
      fs.querySelectorAll("input").forEach((inp) => { inp.disabled = true; });
      corr.replaceChildren(
        el("strong", null, juste ? "Bonne réponse." : `Réponse attendue : ${choix[bon]}.`),
        ...(q.explication ? [" ", q.explication] : []),
      );
      corr.hidden = false;
    });
    const avant = lire(cle);
    const memeTotal = avant && avant.total === nombre;
    ecrire(cle, {
      score, total: nombre,
      meilleur: Math.max(score, memeTotal ? avant.meilleur ?? avant.score : 0),
      essais: (memeTotal ? avant.essais || 1 : 0) + 1,
      date: new Date().toISOString(),
    });
    const pc = Math.round((100 * score) / nombre);
    // Rouge à 50 % et moins, ambre sous 80 %, vert à 80 % et plus
    resultat.className = "quiz-resultat " + (pc <= 50 ? "faible" : pc < 80 ? "moyen" : "fort");
    resultat.replaceChildren(
      el("span", "quiz-score", `${score} / ${nombre}`),
      el("span", "quiz-message", pc === 100 ? "Parfait! Toutes les réponses sont bonnes." :
        pc >= 80 ? "Très bien! Revoyez les questions en rouge ci-dessous." :
        pc > 50 ? "Pas mal. Relisez les sections liées aux questions en rouge." :
        "Relisez le document, puis recommencez le quiz."),
    );
    resultat.hidden = false;
    envoyer.hidden = true;
    compte.hidden = true;
    recommencer.hidden = false;
    deja.hidden = true;
    resultat.scrollIntoView({ behavior: "smooth", block: "center" });
    resultat.focus({ preventScroll: true });
  });
  recommencer.addEventListener("click", () => {
    nouvelEssai();
    titre.scrollIntoView({ behavior: "smooth", block: "start" });
  });

  zone.replaceChildren(titre, intro, deja, resultat, form);
  nouvelEssai();
})();
