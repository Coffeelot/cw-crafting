<template>
  <v-card border variant="flat" class="fill-height mx-auto pa-2">
    <v-card-title class="menu-title">
      <span>Crafting: {{ recipeLabel }} </span>
      <v-btn
        @click="closeCraftingMenu"
        variant="plain"
        density="compact"
        icon="mdi-close"
      ></v-btn>
    </v-card-title>
    <v-card-text>
      <div class="d-flex flex-column">
        <div variant="text" class="horizontal-list">
          <div>
            <h3 class="mb-4">Components needed</h3>
            <div class="chip-holder">
              <v-chip
                v-for="(amount, key) in recipe.materials"
                :key="key"
                :prepend-icon="
                  recipe.keepMaterials && recipe.keepMaterials[key]
                    ? 'mdi-toolbox'
                    : ''
                "
              >
                {{ recipe.materialsNameMap[key] || key }}: {{ amount }}
              </v-chip>
            </div>
          </div>
          <v-divider :vertical="true"></v-divider>
          <div>
            <h3 class="mb-4">Output</h3>
            <div class="chip-holder">
              <v-chip v-for="(amount, key) in recipe.toItems" :key="key">
                {{ recipe.toMaterialsNameMap[key] || key }}:
                {{ amount }}</v-chip
              >
            </div>
          </div>
          <v-divider :vertical="true"></v-divider>
          <div>
            <h3 class="mb-4">Crafting time</h3>
            <span>{{ secondsToHMS(recipe.craftingTime) }}</span>
          </div>
          <v-divider :vertical="true"></v-divider>
          <div>
            <h3 class="mb-4">Skill gain</h3>
            <span>{{ recipe.skillGain }}</span>
          </div>
          <v-avatar v-if="isSingleItem()" rounded="0" class="avatar" size="90px">
        <v-img
          :src="
            getImageLink(undefined, recipe.toMaterialsNameMap, recipe.metadata)
          "
        ></v-img>
      </v-avatar>
      <div v-else>
        <v-avatar
          class="avatar"
          v-for="(item, materialName) in recipe.toItems"
          :key="materialName"
          rounded="0"
          size="80px"
        >
          <v-img
            :src="
              getImageLink(
                materialName,
                recipe.toMaterialsNameMap,
                recipe.metadata
              )
            "
          ></v-img>
        </v-avatar>
      </div>
        </div>
      </div>
      <div>
        <div class="d-flex flex-column ga-2 mt-3">
          <h3>Craft amount: {{ craftingAmount }}</h3>
          <h4>Max: {{ recipe.maxCraft }}</h4>
          <v-slider
            v-on:update:model-value="verifyHasItems()"
            @click="verifyHasItems()"
            v-model="craftingAmount"
            :min="1"
            :max="recipe.maxCraft"
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
              ></v-btn> </template
          ></v-slider>
          <div class="horizontal-list">
            <div>
              <h3 class="mb-2">Items required</h3>
              <div class="chip-holder">
                <v-chip
                  v-for="(amount, key) in recipe.materials"
                  :key="key"
                  :color="
                    hasMaterialMap && hasMaterialMap[key] ? 'green' : 'red'
                  "
                  :prepend-icon="
                    recipe.keepMaterials && recipe.keepMaterials[key]
                      ? 'mdi-toolbox'
                      : ''
                  "
                >
                  {{ recipe.materialsNameMap[key] || key }}:
                  {{ amount * (recipe.keepMaterials && recipe.keepMaterials[key] ? 1 : craftingAmount) }}
                </v-chip>
              </div>
            </div>
            <div v-if="recipe.craftingSkill && recipe.craftingSkill > 0">
              <h3 class="mb-2">Crafting skill required</h3>
              <v-chip :color="craftingSkillIsMet ? 'green' : 'red'">
                {{ recipe.skillData.skillLabel }}:
                {{ recipe.skillData.currentSkill }} / {{ recipe.craftingSkill }}
              </v-chip>
            </div>
            <v-divider
              v-if="recipe.craftingSkill && recipe.craftingSkill > 0"
              :vertical="true"
            ></v-divider>
            <div>
              <h3 class="mb-2">Crafting time</h3>
              <span>{{
                secondsToHMS(recipe.craftingTime * craftingAmount)
              }}</span>
            </div>
            <v-divider :vertical="true"></v-divider>
            <div>
              <h3 class="mb-2">Skill gain</h3>
              <span>{{ recipe.skillGain * craftingAmount }}</span>
            </div>
          </div>
        </div>
      </div>
    </v-card-text>
    <v-card-actions>
      <v-btn
        :disabled="!craftingSkillIsMet || !hasAllMaterials"
        block
        rounded="xl"
        variant="flat"
        color="primary"
        @click="craft"
        >Craft {{ craftingAmount }} batches</v-btn
      >
    </v-card-actions>
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
  const secondsString = seconds > 0 ? seconds + " seconds" : undefined;

  if (minutesString && secondsString)
    return minutesString + ", " + secondsString;
  else if (minutesString) return minutesString;
  else if (secondsString) return secondsString;
  else return "Unknown";
};

const isSingleItem = () =>
  props.recipe.toMaterialsNameMap &&
  Object.keys(props.recipe.toMaterialsNameMap).length === 1;

const updateCraftingAmount = (amount: number) => {
  let newAmount = craftingAmount.value + amount;
  if (newAmount > 0) {
    if (props.recipe.maxCraft && props.recipe.maxCraft < newAmount)
      newAmount = props.recipe.maxCraft;
    craftingAmount.value = newAmount;
    verifyHasItems();
  }
};
const props = defineProps<{
  recipe: Recipe;
}>();

const globalStore = useGlobalStore();
const hasMaterialMap: Ref<Record<string, boolean> | undefined> = ref(undefined);
const craftingAmount = ref(1);

const hasAllMaterials = computed(
  () =>
    hasMaterialMap.value !== undefined &&
    Object.values(hasMaterialMap.value).every((value) => value === true)
);
const craftingSkillIsMet = computed(() =>
  props.recipe.craftingSkill
    ? props.recipe.skillData.currentSkill >= props.recipe.craftingSkill
    : true
);

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
  const res = await api.post(
    "getCanCraft",
    JSON.stringify({
      craftingAmount: craftingAmount.value,
      currentRecipe: globalStore.selectedRecipe,
    })
  );
  hasMaterialMap.value = res.data as Record<string, boolean>;
};
const verifyAmount = async () => {
  if (props.recipe.maxCraft < craftingAmount.value)
    craftingAmount.value = props.recipe.maxCraft;
};

const craft = async () => {
  closeUi();
  await api.post(
    "attemptCrafting",
    JSON.stringify({
      craftingAmount: craftingAmount.value,
      currentRecipe: globalStore.selectedRecipe,
    })
  );
};

const closeCraftingMenu = () => {
  globalStore.$state.selectedRecipe = "";
};

onUpdated(() => {
  verifyHasItems();
  verifyAmount();
});
onMounted(() => verifyHasItems());
</script>

<style scoped lang="scss">
.horizontal-list {
  display: flex;
  gap: 2rem;
}
.menu-title {
  width: 100%;
  display: flex;
  justify-content: space-between;
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
