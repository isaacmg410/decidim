((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;

  const wrapperSelector = ".meeting-agenda-items";
  const fieldSelector = ".meeting-agenda-item";

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".meeting-agenda-item:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".meeting-agenda-item:not(.hidden)",
    hideOnFirstSelector: ".move-up-agenda-item",
    hideOnLastSelector: ".move-down-agenda-item"
  });

  const createSortableList = () => {
    createSortList(".meeting-agenda-items-list:not(.published)", {
      handle: ".agenda-item-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
    });
  };

  const hideDeletedAgendaItem = ($target) => {
    const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

    if (inputDeleted === "true") {
      $target.addClass("hidden");
      $target.hide();
    }
  };

  createDynamicFields({
    placeholderId: "meeting-agenda-item-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".meeting-agenda-items-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-agenda-item",
    removeFieldButtonSelector: ".remove-agenda-item",
    moveUpFieldButtonSelector: ".move-up-agenda-item",
    moveDownFieldButtonSelector: ".move-down-agenda-item",
    onAddField: () => {
      createSortableList();

      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onRemoveField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveUpField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveDownField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    }
  });

  createSortableList();

  $(fieldSelector).each((idx, el) => {
    const $target = $(el);

    hideDeletedAgendaItem($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
})(window);
