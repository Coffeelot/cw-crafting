export type Recipe = {
    label?: string,
    blueprint: string,
    category: string,
    craftingTime: number,
    materials: Record<string, number>,
    materialsNameMap: Record<string, string>,
    toItems: Record<string, number>,
    toMaterialsNameMap: Record<string, string>,
    craftingSkill: number,
    maxCraft?: number,
    type: string,
}

export type Recipes = Record<string, Recipe>

export type Table = {
    title: string,
    icon: string,
}
