// Accueil : met en forme le Markdown d'index.md (sections, cartes, vignettes, encadrés).
// Les règles d'écriture sont dans GUIDE.md. Sans JavaScript, le Markdown s'affiche tel quel.
"use strict";

(function () {
  const root = document.querySelector(".prose.accueil");
  if (!root) return;

  const COULEURS = ["c-cyan", "c-violet", "c-green", "c-amber", "c-red"];
  const SEP = " · ";
  const estDessin = (img) => /(^|\/)dessins\/[^/]+\.svg$/.test(img.getAttribute("src") || "");
  const el = (tag, cls) => { const e = document.createElement(tag); if (cls) e.className = cls; return e; };

  // Le dessin devient un masque coloré par la couleur du texte (thème clair ou sombre).
  // Fureteur sans masques CSS : on garde l'image telle quelle (dessin bleu).
  const avecMasques = CSS.supports("mask-image", "url(x.svg)") || CSS.supports("-webkit-mask-image", "url(x.svg)");
  function masque(img) {
    if (!avecMasques) { const i = el("img", "masque-img"); i.src = img.src; i.alt = ""; return i; }
    const m = el("span", "masque");
    m.style.setProperty("--icon", 'url("' + img.src + '")');
    m.setAttribute("aria-hidden", "true");
    return m;
  }

  // Premier élément significatif d'un nœud (en sautant les espaces).
  function premier(node) {
    for (const n of node.childNodes) {
      if (n.nodeType === 3 && !n.textContent.trim()) continue;
      return n;
    }
    return null;
  }

  // 1. Une section par titre ##
  const sections = [];
  let courante = null;
  for (const n of [...root.childNodes]) {
    if (n.nodeType === 1 && n.tagName === "H2") {
      courante = el("section", "bloc");
      root.insertBefore(courante, n);
      sections.push(courante);
    }
    if (courante) courante.appendChild(n);
  }

  // 2. Sections : dessin, lettre, couleur, vignette de l'en-tête
  const tuiles = [];
  let nLettres = 0, nAutres = 0;
  for (const sec of sections) {
    const h2 = sec.querySelector("h2");
    const titre = h2.textContent.trim();
    const m = titre.match(/^([A-Z])\)\s*(.+)$/);
    const couleur = m ? COULEURS[nLettres++ % 5] : COULEURS[(nAutres++ * 2) % 5];

    // Paragraphe qui suit le titre et commence par un dessin : dessin de la section (+ description)
    let dessin = null, description = "";
    const p = h2.nextElementSibling;
    if (p && p.tagName === "P" && premier(p) && premier(p).tagName === "IMG" && estDessin(premier(p))) {
      dessin = premier(p);
      const em = p.querySelector("em");
      description = (em ? em.textContent : p.textContent).trim();
      p.remove();
    }

    h2.textContent = "";
    if (dessin) { const illus = el("span", "illus " + couleur); illus.append(masque(dessin)); h2.append(illus); }
    if (m) {
      const lettre = el("span", "lettre-txt " + couleur); lettre.textContent = m[1];
      h2.append(lettre, document.createTextNode(" " + m[2]));
      sec.id = "section-" + m[1].toLowerCase();
      tuiles.push({ id: sec.id, lettre: m[1], titre: m[2], description, dessin, couleur });
    } else {
      h2.append(document.createTextNode(titre));
    }
    sec.dataset.couleur = couleur;
  }

  // 3. Listes : cartes de documents, ou encadrés « **Libellé** : valeur »
  for (const ul of root.querySelectorAll(":scope > section > ul")) {
    const items = [...ul.children];
    const sec = ul.closest("section");
    if (items.length && items.every((li) => { const f = premier(li); return f && f.tagName === "IMG"; })) {
      ul.replaceWith(cartes(items, sec.dataset.couleur));
    } else if (items.length && items.every((li) => { const f = premier(li); return f && f.tagName === "STRONG"; })) {
      ul.replaceWith(encadres(items));
    }
  }

  function cartes(items, couleur) {
    const docs = items.map(lireCarte);
    const grille = el("div", "docs " + couleur);
    // Cartes numérotées par une seule lettre (A, B…) : grandes cartes, sauf « grandes_cartes: false » dans index.md
    if (root.dataset.grandesCartes !== "non" && docs.every((d) => /^[A-Z]$/.test(d.numero))) grille.classList.add("grande");
    for (const d of docs) {
      // Avec des liens de plus (« · [Dépôt GitHub](…) ») : la carte est un bloc, son titre est le lien
      // principal (étendu à toute la carte) et les autres liens deviennent des boutons.
      const bloc = d.href && d.autres.length;
      const carte = bloc ? el("div", "doc multi") : d.href ? el("a", "doc") : el("div", "doc sans-lien");
      if (d.href && !bloc) carte.href = d.href;
      const v = el("span", d.photo ? "vignette photo" : "vignette dessin");
      if (d.photo) { const i = el("img"); i.src = d.img.src; i.alt = d.img.alt || ""; i.loading = "lazy"; v.append(i); }
      else v.append(masque(d.img));
      if (d.numero !== "-") { const n = el("span", "n"); n.textContent = d.numero || "+"; if (n.textContent.length > 4) n.classList.add("long"); v.append(n); }
      const info = el("span", "info");
      let t;
      if (bloc) { t = el("a", "titre principal"); t.href = d.href; } else t = el("span", "titre");
      t.textContent = d.titre;
      info.append(t);
      if (d.option) { const o = el("span", "option"); o.textContent = d.option; info.append(o); }
      if (d.notes) { const no = el("span", "notes"); no.textContent = d.notes; info.append(no); }
      if (bloc) {
        const liens = el("span", "liens");
        for (const a of d.autres) { const b = el("a", "lien-sec"); b.href = a.getAttribute("href"); b.textContent = a.textContent.trim(); liens.append(b); }
        info.append(liens);
      }
      carte.append(v, info);
      grille.append(carte);
    }
    return grille;
  }

  // « ![](dessins/x.svg) 21 · [Titre](lien) · étiquette · [Autre lien](…) », avec une sous-liste
  // facultative (notes). Une image qui n'est pas un dessin s'affiche comme photo.
  function lireCarte(li) {
    const img = premier(li);
    const liens = [...li.querySelectorAll(":scope > a")];
    const lien = liens[0] || null;
    const sous = li.querySelector(":scope > ul");
    const copie = li.cloneNode(true);
    copie.querySelector(":scope > img").remove();
    if (copie.querySelector(":scope > ul")) copie.querySelector(":scope > ul").remove();
    [...copie.querySelectorAll(":scope > a")].slice(1).forEach((a) => a.remove());
    const parts = copie.textContent.split("·").map((s) => s.trim()).filter(Boolean);
    let numero = "";
    // Numéro : 1 à 4 lettres ou chiffres (21, 08b, F1, A), un code de cours (420-1C4),
    // « + » (document d'appoint) ou « - » (aucun numéro affiché)
    if (parts.length > 1 && /^([0-9A-Za-z]{1,4}|[0-9]{3}-[0-9A-Za-z]{3}|\+|-)$/.test(parts[0])) numero = parts.shift();
    let titre = parts.shift() || "";
    if (lien) {
      // Un titre de lien peut lui-même contenir « · » : on le reprend en entier.
      const t = lien.textContent.trim();
      const texte = copie.textContent;
      const reste = texte.slice(texte.indexOf(t) + t.length).split("·").map((s) => s.trim()).filter(Boolean);
      titre = t;
      parts.splice(0, parts.length, ...reste);
    }
    return {
      img, photo: !estDessin(img), numero: numero === "+" ? "" : numero, titre,
      href: lien ? lien.getAttribute("href") : null,
      autres: liens.slice(1),
      option: parts.join(SEP),
      notes: sous ? [...sous.children].map((x) => x.textContent.trim()).join(SEP) : "",
    };
  }

  function encadres(items) {
    const dl = el("dl", "faits");
    for (const li of items) {
      const d = el("div");
      const dt = el("dt"); dt.textContent = premier(li).textContent.trim();
      const dd = el("dd");
      const reste = li.cloneNode(true);
      reste.removeChild(premier(reste));
      reste.normalize();
      if (reste.firstChild && reste.firstChild.nodeType === 3) reste.firstChild.textContent = reste.firstChild.textContent.replace(/^\s*:\s*/, "");
      dd.append(...reste.childNodes);
      d.append(dt, dd);
      dl.append(d);
    }
    return dl;
  }

  // 4. Paragraphes : photo seule (avec le paragraphe qui suit), ou rangée de liens (boutons)
  for (const p of root.querySelectorAll(":scope > section > p")) {
    const kids = [...p.childNodes].filter((n) => !(n.nodeType === 3 && !n.textContent.trim()));
    if (kids.length === 1 && kids[0].tagName === "IMG" && !estDessin(kids[0])) {
      const bloc = el("div", "enseignant");
      const texte = el("div");
      p.replaceWith(bloc);
      bloc.append(kids[0], texte);
      let suivant = bloc.nextElementSibling;
      if (suivant && suivant.tagName === "P") texte.append(suivant);
      bloc.closest("section").id = bloc.closest("section").id || "enseignant";
      continue;
    }
    const liens = kids.filter((n) => n.tagName === "A");
    const autres = kids.filter((n) => n.tagName !== "A");
    if (liens.length && autres.every((n) => n.nodeType === 3 && /^[\s·|]*$/.test(n.textContent))) {
      p.className = "liens-horaire";
      p.replaceChildren(...liens);
      liens.forEach((a) => a.classList.add("btn-lien"));
    }
  }

  // 5. Vignettes de l'en-tête, une par section lettrée
  if (tuiles.length) {
    const nav = el("nav", "tiles");
    nav.setAttribute("aria-label", "Sections du cours");
    for (const t of tuiles) {
      const a = el("a", "tile"); a.href = "#" + t.id;
      const art = el("div", "art " + t.couleur);
      if (t.dessin) art.append(masque(t.dessin));
      const l = el("span", "letter " + t.couleur); l.textContent = t.lettre;
      art.append(l);
      const body = el("div", "body");
      const h = el("span", "heading"); h.textContent = t.titre;
      body.append(h);
      if (t.description) { const d = el("span", "desc"); d.textContent = t.description; body.append(d); }
      a.append(art, body);
      nav.append(a);
    }
    root.prepend(nav);
    const ancre = el("div"); ancre.id = "documents";
    document.getElementById(tuiles[0].id).before(ancre);
  }

  // 6. Titre de la bannière : initiales des mots principaux en couleur
  const h1 = document.querySelector(".hero h1.titre-auto");
  if (h1) {
    if (h1.textContent.trim().length > 30) h1.classList.add("long");
    let i = 0;
    const couleurs = ["c-cyan", "c-amber", "c-violet", "c-green"];
    h1.innerHTML = h1.textContent.replace(/(^|\s)(\p{L})(\p{L}{3,})/gu, (tout, esp, ini, suite) =>
      esp + '<span class="' + couleurs[i++ % 4] + '">' + ini + "</span>" + suite);
  }
})();
