<template>
  <div class="flex h-full w-full flex-col justify-start items-start">
    <EditorAction @save-sheet="handleSaveSheet" />

    <div
      v-if="isProtectedEnvironment"
      class="w-full py-1 px-4 bg-warning text-white"
    >
      {{ $t("sql-editor.sql-execute-in-protected-environment") }}
    </div>

    <template v-if="!tabStore.isDisconnected">
      <SQLEditor @save-sheet="handleSaveSheet" />
    </template>
    <template v-else>
      <ConnectionHolder />
    </template>

    <BBModal
      v-if="sqlEditorStore.isShowExecutingHint"
      :title="$t('common.tips')"
      @close="handleClose"
    >
      <ExecuteHint @close="handleClose" />
    </BBModal>
    <BBModal
      v-if="isShowSaveSheetModal"
      :title="$t('sql-editor.save-sheet')"
      @close="handleCloseModal"
    >
      <SaveSheetModal @close="handleCloseModal" @save-sheet="handleSaveSheet" />
    </BBModal>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref } from "vue";

import {
  useTabStore,
  useSQLEditorStore,
  useSheetStore,
  useInstanceStore,
  useDatabaseStore,
} from "@/store";
import { defaultTabName } from "@/utils/tab";
import EditorAction from "./EditorAction.vue";
import SQLEditor from "./SQLEditor.vue";
import ExecuteHint from "./ExecuteHint.vue";
import ConnectionHolder from "./ConnectionHolder.vue";
import SaveSheetModal from "./SaveSheetModal.vue";
import { UNKNOWN_ID } from "@/types";

const tabStore = useTabStore();
const sqlEditorStore = useSQLEditorStore();
const sheetStore = useSheetStore();
const instanceStore = useInstanceStore();
const databaseStore = useDatabaseStore();

const isShowSaveSheetModal = ref(false);

const isProtectedEnvironment = computed(() => {
  const { instanceId } = tabStore.currentTab.connection;
  const instance = instanceStore.getInstanceById(instanceId);
  return instance.environment.tier === "PROTECTED";
});

const allowSave = computed((): boolean => {
  const tab = tabStore.currentTab;
  if (tab.statement === "") {
    return false;
  }
  if (tab.isSaved) {
    return false;
  }
  // Temporarily disable saving and sharing if we are connected to an instance
  // but not a database.
  if (tab.connection.databaseId === UNKNOWN_ID) {
    return false;
  }
  return true;
});

const handleClose = () => {
  sqlEditorStore.setSQLEditorState({
    isShowExecutingHint: false,
  });
};

const handleSaveSheet = async (sheetName?: string) => {
  if (!allowSave.value) {
    return;
  }

  if (tabStore.currentTab.name === defaultTabName.value && !sheetName) {
    isShowSaveSheetModal.value = true;
    return;
  }
  isShowSaveSheetModal.value = false;

  const { name, statement, sheetId } = tabStore.currentTab;
  sheetName = sheetName ? sheetName : name;

  const conn = tabStore.currentTab.connection;
  const database = await databaseStore.getOrFetchDatabaseById(conn.databaseId);
  const sheetUpsert = {
    id: sheetId,
    projectId: database.project.id,
    databaseId: conn.databaseId,
    name: sheetName,
    statement: statement,
  };
  const sheet = await sheetStore.upsertSheet(sheetUpsert);

  tabStore.updateCurrentTab({
    sheetId: sheet.id,
    isSaved: true,
    name: sheetName,
  });
};

const handleCloseModal = () => {
  isShowSaveSheetModal.value = false;
};
</script>
