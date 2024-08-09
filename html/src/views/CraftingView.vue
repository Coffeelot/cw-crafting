<template>
  <div class="ui-container">
    <div class="screen-container" v-if="globalStore.recipes">
      <div class="top">
        <v-card
          width="100%"
          :prepend-icon="
            globalStore.table.icon
              ? `mdi-${globalStore.table.icon}`
              : 'mdi-wrench'
          "
          :title="globalStore.table.title ? globalStore.table.title : ''"
          :subtitle="`Crafting skill: ${globalStore.playerCraftingLevel} (XP: ${globalStore.playerCraftingSkill})`"
        >
        </v-card>
        <FilterMenu></FilterMenu>
      </div>
      <div class="content">
        <RecipesList class="list"></RecipesList>
        <CraftingMenu
          :recipe="globalStore.recipes[globalStore.selectedRecipe]"
          class="menu"
          v-if="globalStore.selectedRecipe"
        ></CraftingMenu>
      </div>
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

.list {
  flex-grow: 1;
  flex-shrink: 4;
  width: 100%;
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

.content {
  display: flex;
  gap: 1em;
  overflow: auto;
}
</style>
