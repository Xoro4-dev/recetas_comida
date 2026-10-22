import { createStore } from './store.js';
import { RECIPE_CATEGORIES, RESTAURANT_CATEGORIES, BUTTONS, parseRecipe, parseMapsUrl, detectSource, guessRecipeCategory, guessRestaurantCategory } from './parser.js';

const $ = (s) => document.querySelector(s);
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const view = $('#view');
const settings = JSON.parse(localStorage.getItem('nosotros:settings') || '{}');
let store, tab = 'love';
const data = { recipes: [], restaurants: [], pings: [] };
const startedAt = Date.now();
const seen = new Set();

if ('serviceWorker' in navigator && location.protocol.startsWith('http')) navigator.serviceWorker.register('./sw.js').catch(() => {});

async function init() {
  if (!settings.name || !settings.space) return setup();
  store = await createStore(settings.space);
  ['recipes', 'restaurants', 'pings'].forEach((c) =>
    store.subscribe(c, (items) => {
      data[c] = items;
      if (c === 'pings') checkPings();
      else render();
    }));
  document.querySelectorAll('#tabs button').forEach((b) => (b.onclick = () => { tab = b.dataset.tab; render(); }));
  render();
}

function setup() {
  view.innerHTML = `<h1>💞 Bienvenidos</h1><div class="card">
    <label>Tu nombre</label><input id="n" placeholder="Ej: Xoro">
    <label>Código de pareja (el mismo en los dos móviles)</label><input id="s" placeholder="Ej: nuestro-codigo-secreto">
    <button class="btn" id="go">Entrar</button></div>`;
  $('#go').onclick = () => {
    const name = $('#n').value.trim(), space = $('#s').value.trim().toLowerCase().replace(/[^a-z0-9-_]/g, '-');
    if (!name || !space) return;
    localStorage.setItem('nosotros:settings', JSON.stringify({ name, space }));
    location.reload();
  };
}

function render() {
  document.querySelectorAll('#tabs button').forEach((b) => b.classList.toggle('on', b.dataset.tab === tab));
  ({ love: renderLove, recipes: renderRecipes, restaurants: renderRestaurants })[tab]();
}

/* ---------- Mimos ---------- */
function renderLove() {
  view.innerHTML = `<h1>💌 Mimos</h1>
    ${store.mode === 'local' ? '<p class="muted">Modo local: los avisos se emulan entre pestañas de este navegador. Configura Firebase para usarlo entre móviles.</p>' : ''}
    ${BUTTONS.map((b) => `<button class="big" data-b="${b.id}" style="background:${b.color}">${b.emoji} ${esc(b.text)}</button>`).join('')}
    <button class="btn ghost" id="push">🔔 Activar notificaciones</button>`;
  view.querySelectorAll('[data-b]').forEach((el) => (el.onclick = async () => {
    await store.add('pings', { from: settings.name, button: el.dataset.b });
    navigator.vibrate?.(50);
    el.textContent = '✔️ Enviado';
    setTimeout(render, 900);
  }));
  $('#push').onclick = async () => alert((await store.enablePush(settings.name)) ? 'Notificaciones activadas' : 'No disponible: configura Firebase y añade la app a la pantalla de inicio.');
}

function checkPings() {
  data.pings.forEach((p) => {
    if (seen.has(p.id)) return;
    seen.add(p.id);
    if (p.from !== settings.name && p.createdAt >= startedAt - 5000) showPing(p);
  });
}

function showPing(p) {
  const b = BUTTONS.find((x) => x.id === p.button);
  if (!b) return;
  const o = $('#overlay');
  o.className = `theme-${b.theme}`;
  o.hidden = false;
  o.innerHTML = `<div class="msg">${b.emoji}<br>${esc(b.text)}</div><div class="from">de ${esc(p.from)}</div>`;
  for (let i = 0; i < 30; i++) {
    const s = document.createElement('span');
    s.className = 'p';
    s.textContent = b.particles[i % b.particles.length];
    s.style.cssText = `left:${Math.random() * 100}%;animation-duration:${3 + Math.random() * 3}s;animation-delay:${Math.random() * 2}s`;
    o.appendChild(s);
  }
  navigator.vibrate?.([200, 100, 200]);
  try { speechSynthesis.speak(Object.assign(new SpeechSynthesisUtterance(b.text), { lang: 'es-ES' })); } catch {}
  o.onclick = () => { o.hidden = true; o.innerHTML = ''; };
  setTimeout(() => o.onclick(), 8000);
}

/* ---------- Recetas ---------- */
function renderRecipes() {
  const groups = RECIPE_CATEGORIES.map((c) => [c, data.recipes.filter((r) => r.category === c)]).filter(([, l]) => l.length);
  view.innerHTML = `<h1>🍳 Recetas</h1>
    <div class="card"><details><summary>＋ Añadir receta</summary>
      <input id="ru" placeholder="Enlace (TikTok, Instagram, WhatsApp...)">
      <textarea id="rt" placeholder="Pega aquí la descripción y/o los comentarios con los ingredientes"></textarea>
      <select id="rc"><option value="">Categoría automática</option>${RECIPE_CATEGORIES.map((c) => `<option>${c}</option>`).join('')}</select>
      <button class="btn" id="radd">Guardar receta</button></details></div>
    ${groups.map(([c, l]) => `<h2>${c}</h2>${l.map(recipeCard).join('')}`).join('') || '<p class="muted">Aún no hay recetas.</p>'}
    ${data.recipes.length ? `<h2>🛒 Todos los ingredientes</h2><div class="card">${allIngredients()}</div>` : ''}`;
  $('#radd').onclick = async () => {
    const url = $('#ru').value.trim(), text = $('#rt').value;
    if (!url && !text.trim()) return;
    const { title, ingredients } = parseRecipe(text);
    await store.add('recipes', {
      title: title || url || 'Receta', url, text, ingredients, source: detectSource(url),
      category: $('#rc').value || guessRecipeCategory(`${title} ${text}`), done: false,
    });
  };
  bindCommon('recipes');
}
function recipeCard(r) {
  return `<div class="card ${r.done ? 'done' : ''}"><div class="row">
    <input type="checkbox" class="chk" data-done="${esc(r.id)}" ${r.done ? 'checked' : ''}>
    <div class="grow t"><b>${esc(r.title)}</b><br><span class="chip">${esc(r.source)}</span>
    ${r.url ? `<a href="${esc(r.url)}" target="_blank" rel="noopener noreferrer">abrir</a>` : ''}</div>
    <button class="btn ghost" data-del="${esc(r.id)}">🗑</button></div>
    ${r.ingredients?.length ? `<details><summary>Ingredientes (${r.ingredients.length})</summary><ul class="ing">${r.ingredients.map((i) => `<li>${esc(i)}</li>`).join('')}</ul></details>` : ''}</div>`;
}
function allIngredients() {
  return data.recipes.filter((r) => r.ingredients?.length)
    .map((r) => `<b>${esc(r.title)}</b><ul class="ing">${r.ingredients.map((i) => `<li>${esc(i)}</li>`).join('')}</ul>`).join('');
}

/* ---------- Restaurantes ---------- */
function renderRestaurants() {
  const groups = RESTAURANT_CATEGORIES.map((c) => [c, data.restaurants.filter((r) => r.category === c)]).filter(([, l]) => l.length);
  view.innerHTML = `<h1>📍 Restaurantes</h1>
    <div class="card"><details><summary>＋ Añadir restaurante</summary>
      <input id="mu" placeholder="Enlace de Google Maps">
      <input id="mn" placeholder="Nombre (opcional, se intenta sacar del enlace)">
      <select id="mc"><option value="">Categoría automática</option>${RESTAURANT_CATEGORIES.map((c) => `<option>${c}</option>`).join('')}</select>
      <button class="btn" id="madd">Guardar</button></details></div>
    ${groups.map(([c, l]) => `<h2>${c}</h2>${l.map(restCard).join('')}`).join('') || '<p class="muted">Aún no hay restaurantes.</p>'}`;
  $('#madd').onclick = async () => {
    const m = parseMapsUrl($('#mu').value);
    if (!m.valid) return alert('Pega un enlace válido de Google Maps');
    const name = $('#mn').value.trim() || m.name || 'Restaurante';
    await store.add('restaurants', { name, url: m.url, category: $('#mc').value || guessRestaurantCategory(name), done: false });
  };
  bindCommon('restaurants');
}
function restCard(r) {
  return `<div class="card ${r.done ? 'done' : ''}"><div class="row">
    <input type="checkbox" class="chk" data-done="${esc(r.id)}" ${r.done ? 'checked' : ''}>
    <div class="grow t"><b>${esc(r.name)}</b><br><a href="${esc(r.url)}" target="_blank" rel="noopener noreferrer">Ver en Maps</a></div>
    <button class="btn ghost" data-del="${esc(r.id)}">🗑</button></div></div>`;
}

function bindCommon(col) {
  view.querySelectorAll('[data-done]').forEach((el) => (el.onchange = () => store.update(col, el.dataset.done, { done: el.checked })));
  view.querySelectorAll('[data-del]').forEach((el) => (el.onclick = () => confirm('¿Borrar?') && store.remove(col, el.dataset.del)));
}

init();
