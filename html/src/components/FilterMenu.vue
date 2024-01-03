<template>
      <v-expansion-panels>
      <v-expansion-panel
        title="Filters"
      >
      <v-expansion-panel-text>
        <h3>Category</h3>
        <v-chip-group
              multiple
              selected-class="text-primary"
              v-model="selectedCategories"
              @update:model-value="updateSelectedCategories()"
            >
              <v-chip
                v-for="tag in categories"
                :key="tag"
                :value="tag"
              >
                {{ tag }}
              </v-chip>
            </v-chip-group>
            <h3>Search</h3>
            <v-text-field
                class="text-field"
                hideDetails
                placeholder="Search with recipe label or with output materials"
                density="compact"
                v-model="search"
                @update:model-value="updateSearch()"
            ></v-text-field>
      </v-expansion-panel-text>
      </v-expansion-panel>
    </v-expansion-panels>
</template>
<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { computed } from "vue";
import { ref } from "vue";
const globalStore = useGlobalStore();
const categories = computed(() => Array.from(new Set(Object.values(globalStore.recipes).map(item => item.category))))
const selectedCategories = ref()
const search = ref('')

const updateSelectedCategories = () => {
    globalStore.$state.selectedCategories = selectedCategories.value ?? []
}

const updateSearch = () => {
    globalStore.$state.search = search.value ?? ''
}

</script>

<style scoped lang="scss">

</style>
