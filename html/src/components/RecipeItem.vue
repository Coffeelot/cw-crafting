<template>
  <v-card
    variant="tonal"
    height="fit-content"
    :key="recipeName"
    :value="recipeName"
    link
    @click="selectRecipe()"
    :width="globalStore.selectedRecipe ? '100%' : 'fit-content'"
  >
    <v-card-title v-text="recipeLabel"></v-card-title>
    <v-card-text class="text">
      <v-chip v-for="(itemAmount, item) in recipe.materials"
        >{{ itemAmount }} {{ recipe.materialsNameMap[item] }}</v-chip
      >
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { Recipe } from "@/store/types";
import { computed, ref } from "vue";

const props = defineProps<{
  recipe: Recipe;
  recipeName: string;
}>();

const globalStore = useGlobalStore();
const reveal = ref(false);

const recipeLabel = computed(() => {
  if (props.recipe.label) {
    return props.recipe.label;
  } else if (
    props.recipe.toMaterialsNameMap &&
    Object.keys(props.recipe.toMaterialsNameMap).length === 1
  ) {
    const key = Object.keys(props.recipe.toMaterialsNameMap)[0];
    return props.recipe.toMaterialsNameMap[key];
  } else {
    return props.recipeName;
  }
});

const selectRecipe = () => {
  globalStore.$state.selectedRecipe = props.recipeName;
}
</script>

<style scoped lang="scss">
.text {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5em;
}
</style>
