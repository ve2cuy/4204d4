// Bouton du thème clair ou sombre, comme sur ve2cuy.com (choix retenu dans localStorage).
"use strict";

(function () {
  const root = document.documentElement;
  const button = document.querySelector(".theme-toggle");
  if (!button) return;
  const label = button.querySelector(".label");
  const current = () => root.dataset.theme || (matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark");
  const refresh = () => {
    const next = current() === "dark" ? "clair" : "sombre";
    label.textContent = next.toUpperCase();
    button.setAttribute("aria-label", "Passer au mode " + next);
    root.dataset.theme = current();
  };
  button.addEventListener("click", () => {
    const theme = current() === "dark" ? "light" : "dark";
    root.dataset.theme = theme;
    try { localStorage.setItem("ve2cuy-theme", theme); } catch (e) {}
    refresh();
  });
  refresh();
})();
