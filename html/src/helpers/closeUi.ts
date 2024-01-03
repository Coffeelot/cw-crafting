import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";

export const closeUi = () => {
    const store = useGlobalStore()
    store.uiIsOpen = false 
    api.post("closeCrafting");
}