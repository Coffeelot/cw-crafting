export type SkillData = {
    skillName: string,
    currentSkill: number,
    skillLabel: string,
    passes: boolean
}

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
    customSkillGain: number,
    skillGain: number,
    keepMaterials: Record<string, boolean>
    skillData: SkillData
    maxCraft: number,
    type: string,
    metadata?: any
}

export type Recipes = Record<string, Recipe>

export type Table = {
    title: string,
    icon: string,
}
