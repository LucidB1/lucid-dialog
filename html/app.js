const APP = new Vue({
  el: "#app",
  data: {
    show: false,
    ped_name: null,
    ped_question: null,
    dialogIndex : null,
    buttons: [

    ],
  },
  methods: {
    setPedName(ped_name) {
      this.ped_question = null;
      this.ped_name = ped_name;
    },
    setPedQuestion(question) {
      this.ped_question = null;
      this.ped_question = question;
    },
    isEmpty(obj) {
      for (var prop in obj) {
        if (obj.hasOwnProperty(prop)) {
          return false;
        }
      }

      return JSON.stringify(obj) === JSON.stringify({});
    },

    setDialogIndex(index){
      this.dialogIndex = index;

    },
    setButtons(payload) {
      this.buttons = [];
      payload.forEach((item, index) => {
        if (item != null) {
          this.buttons.push({
            text: item.text,
            buttonIndex : index + 1,
            icon: item.icon,
            value: item.value,
          });
        }
      });
    },
    setShow(toggle) {
      this.show = toggle;
    },

    handleButtons(e, btn) {

      let btnIndex = btn.buttonIndex;
      let value = btn.value;
      $.post(
          "http://lucid_dialog/triggerevent",
          JSON.stringify({
            btnIndex,
            dialogIndex: this.dialogIndex,
            value
          })
        );
      
    },

    close(){

      $.post("http://lucid_dialog/close");
      this.resetContent();
    },
    resetContent() {
      this.show = false;
      this.ped_name = null;
      this.ped_question = null;
      this.buttons = [];
    },
  },
});


$(document).on("keydown", function () {
  switch (event.keyCode) {
    case 27: //ESC
      $.post("http://lucid_dialog/close");
      APP.resetContent();
      break;
  }
});

window.addEventListener("message", function (event) {
  let item = event.data;
  switch (event.data.action) {
    case "setdialog":
      APP.setPedName(item.name);
      APP.setPedQuestion(item.question);
      APP.setButtons(item.buttons);
      APP.setShow(true);
      APP.setDialogIndex(item.dialogIndex)
      break;
    case "close":
      APP.resetContent();
      break;
    default:
      break;
  }
});
