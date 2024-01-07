<template>
  <v-app theme="dark">
    <transition name="scale" mode="out-in">
      <CraftingView v-if="globalStore.uiIsOpen"></CraftingView>
    </transition>
  </v-app>
</template>

<script lang="ts" setup>
import CraftingView from "./views/CraftingView.vue";
import {
  onMounted,
  onUnmounted,
} from "vue";
import { useGlobalStore } from "./store/global";
import api from "@/api/axios";

const globalStore = useGlobalStore();


const toggleApp = (show: boolean): void => {
  if (show) {
    populateRecipes()
  }
  globalStore.$state.uiIsOpen = show
  globalStore.$state.search = ''
  globalStore.$state.selectedCategories = []
};

const handleMessageListener = (event: MessageEvent) => {
  const itemData: any = event?.data;
  if (itemData?.type) {
    globalStore.$state.table = itemData.table
    switch (itemData.type) {
      case 'toggleUi':
        toggleApp(itemData.toggle)
        break;
      default:
        break;
    }

  }
};

const populateRecipes = async () => {
  const res = await api.post("getRecipes");
  globalStore.$state.recipes = res.data
  if (globalStore.selectedRecipe.length>0 && !globalStore.recipes[globalStore.selectedRecipe]) { globalStore.$state.selectedRecipe = '' }

}

const setInventory = async () => {
  const res = await api.post("getInventory");
  globalStore.$state.oxInventory = res.data
}

onMounted(() => {
  window.addEventListener("message", handleMessageListener);
  setInventory()
});

onUnmounted(() => {
  window.removeEventListener("message", handleMessageListener, false);
});

</script>

<style>
@import './styles/global.scss';

::-webkit-scrollbar {
  width: 0;
  display: inline !important;
}
.v-application {
  background: rgb(0, 0, 0, 0.0) !important;
}

.scale-enter-active,
.scale-leave-active {
  transition: all 0.5s ease;
}

.scale-enter-from,
.scale-leave-to {
  opacity: 0;
  transform: scale(0.9);
}
</style>
