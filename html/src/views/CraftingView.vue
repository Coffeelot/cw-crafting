<template>
  <div class="ui-container">
    <div class="screen-container" v-if="globalStore.recipes">
      <v-card border class="d-flex flex-column main-card" rounded="lg">
        <div class="top">
          <v-card
            width="100%"
            variant="text"
            :prepend-icon="
              globalStore.table.icon
                ? `mdi-${globalStore.table.icon}`
                : 'mdi-wrench'
            "

          >
            <template v-slot:title>
              <div class="d-flex justify-space-between" width="100%">
                <span>{{ globalStore.table.title ? globalStore.table.title : ''}}</span>
                <v-btn @click="closeUi" variant="text" icon="mdi-close">
                    
                </v-btn>
              </div>
            </template>
            <template v-slot:subtitle>
              {{ `Crafting skill: ${globalStore.playerCraftingLevel} (XP: ${globalStore.playerCraftingSkill})` }}
            </template>
          </v-card>
        </div>
        <v-card-text>
          <FilterMenu class="filters"></FilterMenu>
          <div class="content">
            <RecipesList class="list"></RecipesList>
            <CraftingMenu
              :recipe="globalStore.recipes[globalStore.selectedRecipe]"
              class="menu"
              v-if="globalStore.selectedRecipe"
            ></CraftingMenu>
          </div>
        </v-card-text>
      </v-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "../store/global";
import { closeUi } from "@/helpers/closeUi";
import FilterMenu from "@/components/FilterMenu.vue";
import RecipesList from "@/components/RecipesList.vue";
import CraftingMenu from "@/components/CraftingMenu.vue";

const globalStore = useGlobalStore();

document.onkeydown = function (evt) {
  if (evt?.key === "Escape") closeUi();
};
</script>

<style scoped lang="scss">

.top {
  display: flex;
  gap: 1em;
  flex-direction: column;
  align-items: center;
}

.icon-holder {
  min-width: fit-content;
  height: fit-content;
  background: #1d1d24;
  border-radius: 100%;
  padding: 1em;
}
body {
  overflow: hidden;
}

.content {
  display: flex;
  gap: 1em;
  max-height: 59vh;
}

.list {
  flex-grow: 1;
  overflow-y: auto;
  max-height: 59vh;
}

.menu {
  flex-grow: 2;
  width: 100%;
  overflow-y: auto;
}
h2 {
  margin-bottom: 0px;
}

.ui-container {
  z-index: 2000;
  width: 100%;
  position: absolute;
  bottom: 10%;
  display: flex;
  justify-content: center;
  z-index: 2000;
}

.screen-container {
  height: 80vh;
  width: 90%;
  font-family: "Gill Sans", "Gill Sans MT", Calibri, "Trebuchet MS", sans-serif;
  display: flex;
  flex-direction: column;
  gap: 1em;
}

.app-container {
  background: $background;
  overflow-y: hidden;
  overflow-x: hidden;
  position: relative;
  display: flex;
  height: 460px;
}


</style>
