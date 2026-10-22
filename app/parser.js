// Utilidades puras (sin DOM) para analizar recetas y enlaces de Google Maps.

export const RECIPE_CATEGORIES = ['Postres', 'Tartas', 'Arroces', 'Pasta', 'Carnes', 'Pescados', 'Ensaladas', 'Otros'];
export const RESTAURANT_CATEGORIES = ['Italiano', 'Japonés', 'Mexicano', 'Hamburguesas', 'Pizzería', 'Tapas', 'Asiático', 'Otros'];

const RECIPE_KEYWORDS = {
  Tartas: ['tarta', 'cheesecake', 'pastel'],
  Postres: ['postre', 'brownie', 'flan', 'helado', 'mousse', 'galleta', 'natillas', 'tiramisu', 'tiramisú', 'chocolate'],
  Arroces: ['arroz', 'paella', 'risotto'],
  Pasta: ['pasta', 'espagueti', 'macarron', 'lasaña', 'lasagna', 'canelones', 'tallarines', 'carbonara'],
  Carnes: ['pollo', 'carne', 'cerdo', 'ternera', 'hamburguesa', 'costilla', 'albóndiga'],
  Pescados: ['pescado', 'salmón', 'salmon', 'merluza', 'atún', 'bacalao', 'gamba', 'marisco'],
  Ensaladas: ['ensalada', 'bowl'],
};

const RESTAURANT_KEYWORDS = {
  Pizzería: ['pizza', 'pizzer'],
  Italiano: ['italian', 'trattoria', 'pasta', 'osteria'],
  Japonés: ['sushi', 'japon', 'ramen', 'izakaya'],
  Mexicano: ['taco', 'mexic', 'burrito', 'cantina'],
  Hamburguesas: ['burger', 'hamburgues'],
  Tapas: ['tapas', 'taberna', 'bodega', 'bar '],
  Asiático: ['thai', 'china', 'wok', 'asia', 'coreano', 'indio'],
};

const STOP_HEADERS = /^(preparaci[oó]n|elaboraci[oó]n|pasos?|instrucciones|procedimiento|modo de hacer|steps?|directions?|method)\b/i;
const START_HEADER = /^(?:[^\p{L}\d]*)(ingredientes?|ingredients?)\b\s*[:\-]?\s*(.*)$/iu;
const QUANTITY_LINE = /^[\s\-•*·✔️✅▪️]*(\d+([.,/]\d+)?\s*(g|gr|gramos?|kg|ml|cl|l|litros?|cucharadas?|cucharaditas?|cdas?|cdtas?|tazas?|vasos?|dientes?|pizca|u|uds?|unidades?)?\b|un[ao]?\s|media\s|medio\s|pizca|chorrito|al gusto)/i;

function cleanItem(s) {
  return s.replace(/^[\s\-•*·▪️✔️✅👉➡️]+/u, '').replace(/[.;,]+$/, '').trim();
}

export function detectCategory(text, keywords, fallback = 'Otros') {
  const t = ` ${(text || '').toLowerCase()} `;
  for (const [cat, words] of Object.entries(keywords)) {
    if (words.some((w) => t.includes(w))) return cat;
  }
  return fallback;
}

export function detectSource(url = '') {
  if (/tiktok\./i.test(url)) return 'TikTok';
  if (/instagram\./i.test(url)) return 'Instagram';
  if (/wa\.me|whatsapp/i.test(url)) return 'WhatsApp';
  return url ? 'Web' : 'Texto';
}

// Extrae título e ingredientes de un texto pegado (descripción y/o comentarios).
export function parseRecipe(text) {
  const lines = (text || '').split(/\r?\n/).map((l) => l.trim());
  const ingredients = [];
  let inSection = false;
  let found = false;

  for (const line of lines) {
    const m = line.match(START_HEADER);
    if (m) {
      inSection = true;
      found = true;
      if (m[2]) m[2].split(/[,;]\s*/).map(cleanItem).filter(Boolean).forEach((i) => ingredients.push(i));
      continue;
    }
    if (inSection) {
      if (!line || STOP_HEADERS.test(line)) {
        inSection = false;
        continue;
      }
      ingredients.push(cleanItem(line));
    }
  }

  if (!found) {
    lines.filter((l) => QUANTITY_LINE.test(l) && l.length < 80).forEach((l) => ingredients.push(cleanItem(l)));
  }

  const unique = [...new Set(ingredients.filter(Boolean))];
  const firstLine = lines.find((l) => l && !START_HEADER.test(l) && !/^https?:\/\//i.test(l)) || '';
  const title = firstLine.replace(/#\S+/g, '').trim().slice(0, 80);
  return { title, ingredients: unique };
}

// Intenta sacar el nombre del sitio de un enlace de Google Maps.
export function parseMapsUrl(url) {
  const out = { valid: false, name: '', url: (url || '').trim() };
  let u;
  try {
    u = new URL(out.url);
  } catch {
    return out;
  }
  if (!/(^|\.)google\.[a-z.]+$|(^|\.)goo\.gl$|(^|\.)maps\.app\.goo\.gl$/i.test(u.hostname)) return out;
  out.valid = true;
  const place = u.pathname.match(/\/place\/([^/]+)/);
  const q = u.searchParams.get('q') || u.searchParams.get('query');
  const raw = place ? place[1] : q || '';
  try {
    out.name = decodeURIComponent(raw.replace(/\+/g, ' ')).trim();
  } catch {
    out.name = raw.replace(/\+/g, ' ');
  }
  return out;
}

export function guessRestaurantCategory(name) {
  return detectCategory(name, RESTAURANT_KEYWORDS);
}
export function guessRecipeCategory(text) {
  return detectCategory(text, RECIPE_KEYWORDS);
}

export const BUTTONS = [
  { id: 'tequiero', text: 'Te quiero', emoji: '💕', theme: 'love', color: '#ff5d8f', particles: ['💕', '💖', '❤️'] },
  { id: 'teamo', text: 'Te amoooooo', emoji: '😍', theme: 'romantic', color: '#e0115f', particles: ['❤️', '💘', '🌹'] },
  { id: 'cerveza', text: '¿Una servesa?', emoji: '🍺', theme: 'beer', color: '#f5a623', particles: ['🍺', '🍻', '🫧'] },
  { id: 'pitillet', text: '¿Un pitillet?', emoji: '🚬', theme: 'smoke', color: '#6b7280', particles: ['💨', '🚬', '☁️'] },
  { id: 'mimos', text: 'Necesito mimos', emoji: '🥺', theme: 'cuddle', color: '#a78bfa', particles: ['🧸', '🤗', '🥺'] },
];
