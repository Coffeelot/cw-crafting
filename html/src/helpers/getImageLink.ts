import { useGlobalStore } from "@/store/global";

export const getImageLink = (
  material: string | undefined,
  toMaterialsNameMap: Record<string, string>,
  metadata: any
) => {
  const store = useGlobalStore();
  let key = undefined;
  if (metadata?.image) {
    key = metadata.image
  } else {
    if (!material) {
      key = Object.keys(toMaterialsNameMap)[0];
    } else {
      key = material;
    }
  }

  if (store.settings.useLocalImages) {
    return `nui://cw-crafting/images/${key}.png`;
  } else {
    if (store.settings.oxInventory) {
      return `nui://ox_inventory/web/images/${key}.png`;
    } else {
      return `nui://qb-inventory/html/images/${key}`;
    }
  }
};
