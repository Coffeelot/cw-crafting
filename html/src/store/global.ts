import { defineStore } from 'pinia'
import { Recipes, Table } from './types'

export const useGlobalStore = defineStore('global', {
  state: () => ({
    uiIsOpen: false,
    selectedCategories: [] as string[],
    selectedRecipe: '',
    search: '',
    recipes: {} as Recipes,
    table: {} as Table,
    isLoadingBaseData: true,
    playerCraftingSkill: 0,
    playerCraftingLevel: 0,
    settings: {
      oxInventory: false,
      useLocalImages: false,
    }
  })
})
