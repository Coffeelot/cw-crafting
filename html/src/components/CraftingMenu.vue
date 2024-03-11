<template>
  <v-card
    class="mx-auto pa-2"
  >
    <v-card-title>
      Crafting: {{ recipeLabel }} 
    </v-card-title>
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
            <v-img :src="getImageLink(undefined, recipe.toMaterialsNameMap)"></v-img>
          </v-avatar>
          <div v-else >
            <v-avatar class="avatar" v-for="item, materialName in recipe.toItems" rounded="0"  size="80px">
              <v-img :src="getImageLink(materialName, recipe.toMaterialsNameMap)"></v-img>
            </v-avatar>
          </div>
       </v-card>
       <v-card variant="tonal">
        <v-card-title>Crafting</v-card-title>
        <v-card-text>
          <h3>Craft amount: {{ craftingAmount }}</h3>
          <h4>Max: {{ recipe.maxCraft ? recipe.maxCraft : 10 }}</h4>
          <v-slider
            v-on:update:model-value="verifyHasItems()"
            @click="verifyHasItems()"
            v-model="craftingAmount"
            :min="1"
            :max="recipe.maxCraft ? recipe.maxCraft : 10"
            :step="1"
            thumb-label
          >
          <template v-slot:prepend>
              <v-btn
                size="small"
                variant="text"
                icon="mdi-minus"
                @click="updateCraftingAmount(-1)"
              ></v-btn>
            </template>

            <template v-slot:append>
              <v-btn
                size="small"
                variant="text"
                icon="mdi-plus"
                @click="updateCraftingAmount(1)"
              ></v-btn>
            </template></v-slider>
            <div class="requirements">
              <div>
                <h3 class="mb-2">Items required</h3>
                <div class="chip-holder">
                  <v-chip v-for="(amount, key) in recipe.materials" :color="hasMaterialMap && hasMaterialMap[key] ? 'green':'red'"> {{ recipe.materialsNameMap[key] || key }}: {{ amount*craftingAmount }}</v-chip>
                </div>
              </div>
              <v-divider :vertical="true"></v-divider>
              <div v-if="recipe.craftingSkill>0" >
                <h3 class="mb-2">Crafting skill required</h3>
                <v-chip :color="craftingSkillIsMet ? 'green':'red'"> Skill Requirement: {{ recipe.craftingSkill }} </v-chip>
              </div>
              <v-divider v-if="recipe.craftingSkill>0" :vertical="true"></v-divider>
              <div>
              <h3 class="mb-2">Crafting time</h3>
                <span>{{ secondsToHMS(recipe.craftingTime*craftingAmount) }}</span>
              </div>
            </div>
            </v-card-text>
            <v-card-actions>
              <v-btn :disabled="!craftingSkillIsMet || !hasAllMaterials " block variant="tonal" @click="craft">Craft {{ craftingAmount }} batches</v-btn>
            </v-card-actions>
      </v-card>
        </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeUi } from "@/helpers/closeUi";
import { getImageLink } from "../helpers/getImageLink";
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
const updateCraftingAmount = ( amount:number) => {
  let newAmount = craftingAmount.value + amount;
  if (newAmount > 0 ) {
    if (props.recipe.maxCraft && props.recipe.maxCraft < newAmount) newAmount = props.recipe.maxCraft
    craftingAmount.value = newAmount
    verifyHasItems()
  }
}
const props = defineProps<{
  recipe: Recipe
}>()

const globalStore = useGlobalStore();
const hasMaterialMap: Ref<Record<string, boolean> | undefined>= ref(undefined)
const craftingAmount = ref(1)

const hasAllMaterials = computed(() => hasMaterialMap.value !== undefined && Object.values(hasMaterialMap.value).every(value => value === true))
const craftingSkillIsMet = computed(() => globalStore.playerCraftingSkill >= props.recipe.craftingSkill)

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

const verifyHasItems = async () => {
  const res = await api.post("getCanCraft", JSON.stringify({craftingAmount: craftingAmount.value, currentRecipe: globalStore.selectedRecipe}));
  hasMaterialMap.value = res.data as Record<string, boolean>
}

const craft = async () => {
  closeUi()
  await api.post("attemptCrafting", JSON.stringify({craftingAmount: craftingAmount.value, currentRecipe: globalStore.selectedRecipe}));
}

onUpdated(()=> verifyHasItems())
onMounted(()=> verifyHasItems())

</script>

<style scoped lang="scss">
.requirements {
  display: flex;
  gap: 2rem;
}
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
