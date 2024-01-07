// Utilities
import { defineStore } from 'pinia'
import { Recipe, Recipes, Table } from './types'

export const useGlobalStore = defineStore('global', {
  state: () => ({
    oxInventory: false,
    uiIsOpen: false,
    selectedCategories: [] as string[],
    selectedRecipe: '',
    search: '',
    recipes: {} as Recipes,
    table: {} as Table,
    isLoadingBaseData: true,
  })
})
