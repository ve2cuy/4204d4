// Tableau de bord de la session (semaine courante), repris de ve2cuy.com (accueil/main.js).
"use strict";

// --- Tableau de bord -----------------------------------------------------

const DAY = 86400000;

function isoDay(d) {
  const pad = (n) => String(n).padStart(2, "0");
  return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
}

function parseDay(s) {
  return new Date(s + "T12:00:00");
}

function longDate(s) {
  return parseDay(s).toLocaleDateString("fr-CA", { weekday: "long", day: "numeric", month: "long", year: "numeric" });
}

function shortDate(s) {
  return parseDay(s).toLocaleDateString("fr-CA", { day: "numeric", month: "short" });
}

// « 15–19 mars », ou « 29 mars–2 avr. » à cheval sur deux mois.
function dateRange(a, b) {
  if (a.slice(0, 7) === b.slice(0, 7)) return parseDay(a).getDate() + "–" + shortDate(b);
  return shortDate(a) + "–" + shortDate(b);
}

// Date du jour, ou celle de ?date=AAAA-MM-JJ pour les essais.
function today() {
  const forced = new URLSearchParams(location.search).get("date");
  if (forced && /^\d{4}-\d{2}-\d{2}$/.test(forced) && !isNaN(parseDay(forced))) return forced;
  return isoDay(new Date());
}

// La session en cours, sinon la prochaine, sinon la dernière.
function pickSession(sessions, day) {
  const sorted = sessions.slice().sort((a, b) => a.debut.localeCompare(b.debut));
  return sorted.find((s) => day <= s.evaluations[1]) || sorted[sorted.length - 1];
}

function status(session, day) {
  const weeks = session.semaines;
  const total = weeks.length;
  const [majStart, majEnd] = session.mise_a_jour;
  const [evalStart, evalEnd] = session.evaluations;
  // Fin de semaine collée à la semaine de mise à jour : elle en fait partie.
  const majFrom = isoDay(new Date(parseDay(majStart) - 2 * DAY));
  const majTo = isoDay(new Date(parseDay(majEnd).getTime() + 2 * DAY));
  const breakAfter = weeks.findIndex((w) => w[0] > majStart); // semaines avant la mise à jour

  if (day < session.debut) {
    const n = Math.ceil((parseDay(session.debut) - parseDay(day)) / DAY);
    return { state: "avant la session", tone: "muted", week: null, left: total, done: 0,
      note: "La session " + session.nom.toLowerCase().replace(/^(\w+)/, "d'$1") + " commence le " + longDate(session.debut) + ", dans " + n + (n > 1 ? " jours." : " jour."), breakAfter };
  }
  if (day >= majFrom && day <= majTo) {
    return { state: "semaine de mise à jour", tone: "violet", week: breakAfter, left: total - breakAfter, done: breakAfter, inBreak: true,
      note: "Semaine de mise à jour du " + shortDate(majStart) + " au " + shortDate(majEnd) + " : aucun cours. Reprise le " + longDate(weeks[breakAfter][0]) + ", semaine " + (breakAfter + 1) + ".", breakAfter };
  }
  if (day <= session.fin_cours) {
    let week = weeks.findIndex((w) => w[w.length - 1] >= day) + 1;
    const classDay = weeks[week - 1].includes(day);
    const next = weeks[week - 1].find((d) => d >= day);
    return { state: "en session", tone: "green", week, left: total - week, done: week - 1, now: week,
      note: classDay ? "Jour de classe, semaine " + week + " de " + total + "." : "Prochain jour de classe : " + longDate(next) + ", semaine " + week + ".", breakAfter };
  }
  if (day <= evalEnd) {
    return { state: "évaluations", tone: "cyan", week: total, left: 0, done: total,
      note: ("Période d'évaluation commune du " + shortDate(evalStart) + " au " + shortDate(evalEnd) + ".").replace(/\.\.$/, "."), breakAfter };
  }
  return { state: "session terminée", tone: "muted", week: total, left: 0, done: total,
    note: "La session " + session.nom.toLowerCase().replace(/^(\w+)/, "d'$1") + " est terminée.", breakAfter };
}

function renderDashboard(session, day) {
  const s = status(session, day);
  const total = session.semaines.length;
  const $ = (id) => document.getElementById(id);

  $("cal-today").textContent = longDate(day);
  const state = $("cal-state");
  state.textContent = s.state;
  state.className = s.tone === "muted" ? "" : "c-" + s.tone;

  const week = $("cal-week");
  week.textContent = s.week ? String(s.week) : "—";
  if (s.week) {
    const of = document.createElement("small");
    of.textContent = " / " + total;
    week.append(of);
  }
  $("cal-left").textContent = String(s.left);
  $("cal-year").textContent = session.annee_scolaire;
  $("cal-session").textContent = "session " + session.nom.toLowerCase().replace(/^(\w+)/, "d'$1");
  $("cal-note").textContent = s.note;

  const bar = $("cal-bar");
  bar.replaceChildren();
  for (let i = 1; i <= total; i++) {
    const seg = document.createElement("span");
    if (i === s.now) seg.className = "now";
    else if (i <= s.done) seg.className = "done";
    bar.append(seg);
    if (i === s.breakAfter) {
      const gap = document.createElement("span");
      gap.className = s.inBreak ? "break now" : "break";
      bar.append(gap);
    }
  }
  bar.setAttribute("aria-label", s.week ? "Semaine " + s.week + " sur " + total : "La session n'est pas commencée");

  const legend = $("cal-legend");
  legend.replaceChildren();
  for (const text of [
    shortDate(session.debut) + " · début",
    dateRange(session.mise_a_jour[0], session.mise_a_jour[1]) + " · mise à jour",
    shortDate(session.fin_cours) + " · fin des cours",
  ]) {
    const item = document.createElement("span");
    item.textContent = text;
    legend.append(item);
  }
}

async function setupDashboard() {
  try {
    const response = await fetch(document.querySelector(".meter").dataset.sessions, { cache: "no-cache" });
    let sessions = await response.json();
    // saison: automne (ou hiver) dans _config.yml : seulement les sessions de cette saison.
    const saison = (document.querySelector(".meter").dataset.saison || "").toLowerCase();
    if (saison) {
      const choisies = sessions.filter((s) => s.nom.toLowerCase().startsWith(saison));
      if (choisies.length) sessions = choisies;
    }
    const day = today();
    renderDashboard(pickSession(sessions, day), day);
  } catch (e) {
    document.getElementById("cal-note").textContent = "Le calendrier de la session n'a pas pu être chargé.";
  }
}

if (document.querySelector(".meter")) setupDashboard();
