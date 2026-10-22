import test from 'node:test';
import assert from 'node:assert/strict';
import { parseRecipe, parseMapsUrl, guessRecipeCategory, guessRestaurantCategory, detectSource } from '../app/parser.js';

test('extrae ingredientes de una sección', () => {
  const r = parseRecipe('Tarta de queso fácil #tarta\nIngredientes:\n- 500g queso crema\n- 3 huevos\n\nPreparación:\nMezclar todo');
  assert.equal(r.title, 'Tarta de queso fácil');
  assert.deepEqual(r.ingredients, ['500g queso crema', '3 huevos']);
});
test('ingredientes en línea', () => {
  assert.deepEqual(parseRecipe('Ingredientes: harina, huevos, leche').ingredients, ['harina', 'huevos', 'leche']);
});
test('sin cabecera usa cantidades', () => {
  const r = parseRecipe('Mi receta\n200 g de arroz\n1 cebolla\nSe cuece mucho rato en la olla con cariño y paciencia.');
  assert.deepEqual(r.ingredients, ['200 g de arroz', '1 cebolla']);
});
test('categorías', () => {
  assert.equal(guessRecipeCategory('Paella de marisco'), 'Arroces');
  assert.equal(guessRecipeCategory('algo raro'), 'Otros');
  assert.equal(guessRestaurantCategory('Pizzeria Napoli'), 'Pizzería');
});
test('google maps', () => {
  const r = parseMapsUrl('https://www.google.com/maps/place/Casa+Lola/@37.1,-5.9,17z');
  assert.ok(r.valid);
  assert.equal(r.name, 'Casa Lola');
  assert.equal(parseMapsUrl('https://example.com').valid, false);
  assert.equal(parseMapsUrl('nada').valid, false);
});
test('origen', () => {
  assert.equal(detectSource('https://vm.tiktok.com/x'), 'TikTok');
});
