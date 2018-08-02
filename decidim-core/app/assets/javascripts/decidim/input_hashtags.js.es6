/* eslint-disable require-jsdoc, func-style */
/* eslint no-use-before-define: ["error", { "variables": false }] */
/* global Tribute*/

// = require tribute

$(() => {
  const $hashtagContainer = $(".js-hashtags");
  const nodatafound = $hashtagContainer.attr("data-noresults");
  // const sources = [];

  // EXAMPLE DATA
  // tag & name properties are mandatory
  //
  // const sources = [{
  //     "tag": "barrera",
  //     "name": "Collins Franklin",
  //   },
  //   {
  //     "tag": "woods",
  //     "name": "Nadine Buck",
  //   }]


  // Listener for the event triggered by quilljs
  let cursor = "";
  $hashtagContainer.on("quill-position", function(event) {
    if (event.detail !== null) {
      cursor = event.detail.index;
    }
  });

  function remoteSearch(text, cb) {
    return $.get("/api/hashtags/hashtags", function(data) {
      cb(data)
    }).fail(function() {
      cb([])
    }).always(function () {
      // This function runs Tribute every single time you type somthing
      // So we must evalute DOM properties after each
      const $parent = $(tribute.current.element).parent()
      $parent.addClass("is-active")

      // We need to move the container to the wrapper selected
      const $tribute = $parent.find(".tribute-container");
      // Remove the inline styles, relative to absolute positioning
      $tribute.removeAttr("style");
    })
  }

  // tribute.js docs - http://github.com/zurb/tribute
  let tribute = new Tribute({
    trigger: "#",
    // values: sources,
    values: function (text, cb) {
      remoteSearch(text, (hashtags) => cb(hashtags));
    },
    positionMenu: false,
    fillAttr: "name",
    noMatchTemplate: () => `<li>${nodatafound}</li>`,
    lookup: (item) => item.name,
    // lookup: (item) => item.tag + item.name,
    selectTemplate: function(item) {
      if (typeof item === "undefined") {
        return null;
      }
      if (this.range.isContentEditable(this.current.element)) {
        // Check quill.js
        if ($(this.current.element).hasClass("editor-container")) {
          let quill = this.current.element.__quill;
          quill.insertText(cursor - 1, `#${item.original.name} `, Quill.sources.API);
          // quill.insertText(cursor - 1, `#${item.original.tag} `, Quill.sources.API);
          // cursor position + nickname length + "@" sign + space
          let position = cursor + item.original.name.length + 2;
          // let position = cursor + item.original.tag.length + 2;

          let next = 0;
          if (quill.getLength() > position) {
            next = position
          } else {
            next = quill.getLength() - 1
          }
          // Workaround https://github.com/quilljs/quill/issues/731
          setTimeout(function () {
            quill.setSelection(next, 0);
          }, 500);

          return ""
        }
        // return `<span contenteditable="false">#${item.original.tag}</span>`;
        return `<span contenteditable="false">#${item.original.name}</span>`;
      }
      // return `#${item.original.tag}`;
      return `#${item.original.name}`;
    },
    menuItemTemplate: function(item) {
      // let tpl = `<strong>${item.original.tag}</strong>&nbsp;<small>${item.original.name}</small>`;
      let tpl = `<strong>${item.original.name}</strong>`;
      return tpl;
    }
  });

  // console.log($hashtagContainer);

  tribute.attach($hashtagContainer);

  $hashtagContainer.on("tribute-replaced", function() {
    tribute.hideMenu()
  });

  // DOM manipulation
  $hashtagContainer.on("focusin", (event) => {
    // Set the parent container relative to the current element
    tribute.menuContainer = event.target.parentNode;
  });

  $hashtagContainer.on("focusout", (event) => {
    let $parent = $(event.target).parent();

    if ($parent.hasClass("is-active")) {
      $parent.removeClass("is-active");
    }
  });
});
