// = require jquery
// = require rails-ujs
// = require decidim/foundation
// = require modernizr
// = require svg4everybody.min
// = require morphdom
// = require moment.min
// = require foundation-datepicker
// = require form_datepicker

// = require decidim/history
// = require decidim/append_elements
// = require decidim/user_registrations
// = require decidim/account_form
// = require decidim/data_picker
// = require decidim/append_redirect_url_to_modals

// = require jquery.atwho

/* globals svg4everybody */

window.Decidim = window.Decidim || {};

$(() => {
  if (window.Decidim.DataPicker) {
    window.theDataPicker = new window.Decidim.DataPicker($(".data-picker"));
  }
  $(document).foundation();
  svg4everybody();
  if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }


  // $('[data-behavior=hashtaggable]').atwho({
  //   at:"#",
  //   insertTpl: '#${name}',
  //   callbacks: {
  //     remoteFilter: function(query, callback){
  //       if (query.length < 3){
  //         return false
  //       }else{
  //         $.getJSON('/api/hashtags/hashtags', { q: query }, function(data) {
  //           callback(data)
  //         });
  //       }
  //     }
  //   }
  // });


//   $(this.editor.root).atwho({
//     at: '@',
//     data: '/api/users?sortBy=username&sortDir=asc&ignoreme=true',
//     tpl: "<li data-value='${atwho-at}${username}' style='white-space: nowrap'><div class='avatar-clip small'><img src='${picture}' height='40' width='40' class='avatar' onerror=this.style.display='none' /></div>&nbsp;<span style='white-space: nowrap'>${agent_name}</span></li>"
// });

});
