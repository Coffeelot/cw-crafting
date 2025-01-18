<template>
  <v-card
    border
    rounded="lg"
    variant="tonal"
    :color="isSelected ? 'primary' : ''"
    height="fit-content"
    :key="recipeName"
    :value="recipeName"
    link
    @click="selectRecipe()"
    :width="globalStore.selectedRecipe ? '100%' : 'fit-content'"
    :title="recipeLabel"
  >
    <template v-slot:prepend>
      <v-badge
        v-if="recipe.type !== 'breakdown' && !isSingleItem()"
        color="green"
        :content="'+' + (amountOfMaterials() - 1)"
      >
        <v-avatar>
          <v-img :src="imageLink"></v-img>
        </v-avatar>
      </v-badge>
      <v-avatar v-else>
        <v-img :src="imageLink"></v-img>
      </v-avatar>
    </template>
    <v-card-text class="text">
      <v-chip
        v-if="recipe.craftingSkill && recipe.craftingSkill > 0"
        :color="craftingSkillIsMet ? 'green' : 'red'"
      >
        {{ recipe.skillData.skillLabel }}: {{ recipe.craftingSkill }}
      </v-chip>
      <v-chip 
        v-for="(itemAmount, item) in recipe.materials"
        :key="item"
        :prepend-icon="recipe.keepMaterials && recipe.keepMaterials[item] ? 'mdi-toolbox' : ''"
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
const imageLink = computed(() => {
  if (props.recipe.type == "breakdown") {
    return getImageLink(
      Object.keys(props.recipe.materialsNameMap)[0],
      props.recipe.materialsNameMap,
      props.recipe.metadata
    );
  }
  return getImageLink(
    Object.keys(props.recipe.toMaterialsNameMap)[0],
    props.recipe.toMaterialsNameMap,
    props.recipe.metadata
  );
});
const isSingleItem = () =>
  props.recipe.toMaterialsNameMap &&
  Object.keys(props.recipe.toMaterialsNameMap).length === 1;
const amountOfMaterials = () =>
  Object.keys(props.recipe.toMaterialsNameMap).length;

const craftingSkillIsMet = computed(
  () => props.recipe.skillData.currentSkill >= props.recipe.craftingSkill
);

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

const isSelected = computed(() => globalStore.$state.selectedRecipe === props.recipeName)
</script>

<style scoped lang="scss">
.text {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5em;
}
</style>
