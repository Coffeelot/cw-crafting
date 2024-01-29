<template>
  <v-card
    variant="tonal"
    height="fit-content"
    :key="recipeName"
    :value="recipeName"
    link
    @click="selectRecipe()"
    :width="globalStore.selectedRecipe ? '100%' : 'fit-content'"
    :title="recipeLabel"
  >
    <template v-if="isSingleItem()" v-slot:prepend>
      <v-avatar>
        <v-img
          :src="
            imageLink
          "
        ></v-img>
      </v-avatar>
    </template>
    <v-card-subtitle>
      <v-chip v-if="recipe.craftingSkill>0" :color="craftingSkillIsMet ? 'green':'red'"> Skill Requirement: {{ recipe.craftingSkill }} </v-chip>
    </v-card-subtitle>
    <v-card-text class="text">
      <v-chip v-for="(itemAmount, item) in recipe.materials"
        >{{ itemAmount }} {{ recipe.materialsNameMap[item] }}</v-chip
      >
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { getImageLink } from "../helpers/getImageLink";
import { useGlobalStore } from "@/store/global";
import { Recipe } from "@/store/types";
import { computed, ref } from "vue";

const props = defineProps<{
  recipe: Recipe;
  recipeName: string;
}>();

const globalStore = useGlobalStore();
const imageLink = computed(()=> getImageLink(
              Object.keys(props.recipe.toMaterialsNameMap)[0],
              props.recipe.toMaterialsNameMap
            ))
const isSingleItem = () =>
  props.recipe.toMaterialsNameMap &&
  Object.keys(props.recipe.toMaterialsNameMap).length === 1;
const craftingSkillIsMet = computed(() => globalStore.playerCraftingSkill >= props.recipe.craftingSkill)

const recipeLabel = computed(() => {
  if (props.recipe.label) {
    return props.recipe.label;
  } else if (isSingleItem()) {
    const key = Object.keys(props.recipe.toMaterialsNameMap)[0];
    return props.recipe.toMaterialsNameMap[key];
  } else {
    return props.recipeName;
  }
});

const selectRecipe = () => {
  globalStore.$state.selectedRecipe = props.recipeName;
};
</script>

<style scoped lang="scss">
.text {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5em;
}
</style>
