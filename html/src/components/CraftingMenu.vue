<template>
  <v-card
    class="mx-auto pa-2"
  >
    <v-card-title>Crafting: {{ recipeLabel }}</v-card-title>
    <v-card-text>
      <v-card variant="tonal" class="mb-6 d-flex flex-no-wrap justify-space-between align-center">
        <div>
        <v-card-title>Recipe</v-card-title>
        <v-card-text>
          <h3>Components needed</h3>
          <div class="chip-holder">
            <v-chip v-for="(amount, key) in recipe.materials"> {{ recipe.materialsNameMap[key] || key}}: {{ amount }}</v-chip>
          </div>
          <h3 class="mt-4">Output</h3>
          <div class="chip-holder">
            <v-chip v-for="(amount, key) in recipe.toItems"> {{ recipe.toMaterialsNameMap[key] || key}}: {{ amount }}</v-chip>
          </div>
          <h3 class="mt-4">Crafting time</h3>
          <span>{{ secondsToHMS(recipe.craftingTime) }}</span>
        </v-card-text>
      </div>
          <v-avatar v-if="isSingleItem()" rounded="0" class="avatar" size="90px">
            <v-img :src="imageLink(undefined)"></v-img>
          </v-avatar>
          <div v-else >
            <v-avatar class="avatar" v-for="item, materialName in recipe.toItems" rounded="0"  size="80px">
              <v-img :src="imageLink(materialName)"></v-img>
            </v-avatar>
          </div>
       </v-card>
       <v-card variant="tonal">
        <v-card-title>Crafting</v-card-title>
        <v-card-text>
          <h3>Craft amount: {{ craftingAmount }}</h3>
          <v-slider
            v-on:update:model-value="canCraft()"
            @click="canCraft()"
            v-model="craftingAmount"
            :min="1"
            :max="100"
            :step="1"
            thumb-label
          >
          <template v-slot:prepend>
              <v-btn
                size="small"
                variant="text"
                icon="mdi-minus"
                @click="craftingAmount--; canCraft()"
              ></v-btn>
            </template>

            <template v-slot:append>
              <v-btn
                size="small"
                variant="text"
                icon="mdi-plus"
                @click="craftingAmount++; canCraft()"
              ></v-btn>
            </template></v-slider>
            <div class="chip-holder">
              <v-chip v-for="(amount, key) in recipe.materials" :color="hasMaterialMap && hasMaterialMap[key] ? 'green':'red'"> {{ recipe.materialsNameMap[key] || key }}: {{ amount*craftingAmount }}</v-chip>
            </div>
            <h3 class="mt-4">Crafting time</h3>
            <span>{{ secondsToHMS(recipe.craftingTime*craftingAmount) }}</span>
            </v-card-text>
            <v-card-actions>
              <v-btn :disabled="!hasAllMaterials" block variant="tonal" @click="craft">Craft {{ craftingAmount }} batches</v-btn>
            </v-card-actions>
      </v-card>
        </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeUi } from "@/helpers/closeUi";
import { useGlobalStore } from "@/store/global";
import { Recipe } from "@/store/types";
import { onUpdated } from "vue";
import { onMounted } from "vue";
import { Ref, computed, ref } from "vue";

const secondsToHMS = (input: number) => {
    const seconds = Math.floor((input / 1000) % 60);
    const minutes = Math.floor((input / (60 * 1000)) % 60);
    const minutesString = minutes > 0 ? minutes + " minutes" : undefined;
    const secondsString = seconds > 0 ? seconds + " seconds": undefined;

    if (minutesString && secondsString) return minutesString + ", " + secondsString
    else if (minutesString) return minutesString
    else if (secondsString) return secondsString
    else return 'Unknown'
}
const isSingleItem = () => props.recipe.toMaterialsNameMap && Object.keys(props.recipe.toMaterialsNameMap).length === 1

const imageLink = (material: string | undefined) => {
  let key = undefined
  if (!material) {
    key = Object.keys(props.recipe.toMaterialsNameMap)[0] 
  } else {
    key = props.recipe.toMaterialsNameMap[material];
  }
    if (globalStore.oxInventory) {
      return `nui://ox_inventory/web/images/${key}.png`
    } else {
      return `nui://qb-inventory/html/images/${key}`
    }
}

const props = defineProps<{
  recipe: Recipe
}>()

const globalStore = useGlobalStore();
const hasMaterialMap: Ref<Record<string, boolean> | undefined>= ref(undefined)
const craftingAmount = ref(1)

const hasAllMaterials = computed(() => hasMaterialMap.value !== undefined && Object.values(hasMaterialMap.value).every(value => value === true))

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
    return globalStore.selectedRecipe;
  }
});

const canCraft = async () => {
  const res = await api.post("getCanCraft", JSON.stringify({craftingAmount: craftingAmount.value, currentRecipe: globalStore.selectedRecipe}));
  hasMaterialMap.value = res.data as Record<string, boolean>
}

const craft = async () => {
  const res = await api.post("attemptCrafting", JSON.stringify({craftingAmount: craftingAmount.value, currentRecipe: globalStore.selectedRecipe}));
  if (res.data) {
    closeUi()
  }
}

onUpdated(()=> canCraft())
onMounted(()=> canCraft())

</script>

<style scoped lang="scss">
.avatar {
  margin-right: 1rem;
}
.chip-holder {
  display: flex;
  flex-direction: row;
  gap: 0.5em;
  flex-wrap: wrap;
  overflow: auto;
  margin-top: 0.5em;
}


</style>
