<template>
  <v-card class="mx-auto pa-2">
    <div class="recipe-list">
      <RecipeItem
        v-for="(item, i) in filteredRecipes"
        :recipe="item"
        :recipeName="i"
      ></RecipeItem>
    </div>
  </v-card>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import RecipeItem from "./RecipeItem.vue";
import { computed } from "vue";
import { Recipe, Recipes } from "@/store/types";
const globalStore = useGlobalStore();

const handleSearch = (recipe: Recipe, recipeKey: string) => {
  if (globalStore.search.length === 0) {
    return true;
  } else {
    if (
      recipe.label?.toLowerCase().includes(globalStore.search.toLowerCase()) ||
      Object.values(recipe.toMaterialsNameMap)
        .some((value) => value.toLowerCase().includes(globalStore.search.toLowerCase())) ||
      recipeKey.toLowerCase().includes(globalStore.search.toLowerCase())
    ) {
      return true;
    }
  }
  return false;
};

const filteredRecipes = computed(() => {
  const recipesFiltered: Recipes = {};
  for (const recipeKey in globalStore.recipes) {
    if (globalStore.recipes.hasOwnProperty(recipeKey)) {
      const recipe = globalStore.recipes[recipeKey];
      if (globalStore.selectedCategories.length > 0) {
        if (globalStore.selectedCategories.includes(recipe.category)) {
          if (handleSearch(recipe, recipeKey)) {
            recipesFiltered[recipeKey] = recipe;
          }
        }
      } else {
        if (handleSearch(recipe, recipeKey)) {
          recipesFiltered[recipeKey] = recipe;
        }
      }
    }
  }
  return recipesFiltered;
});
</script>

<style scoped lang="scss">
.recipe-list {
  display: flex;
  flex-direction: row;
  gap: 1em;
  flex-wrap: wrap;
  align-content: flex-start;
  overflow: auto;
  height: 100%;
}
</style>
