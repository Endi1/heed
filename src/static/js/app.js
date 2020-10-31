let markAsRead = (itemId, element) => {
  let xhr = new XMLHttpRequest();
  const domain = window.location.hostname;
  const port = location.port;
  let formData = new FormData();
  formData.append("item_id", itemId);


  xhr.open("POST", `http://${domain}:${port}/mark-read`, true);
  xhr.send(formData);
};

let refreshFeeds = () => {
  let xhr = new XMLHttpRequest();
  const domain = window.location.hostname;
  const port = location.port;

  xhr.open("POST", `http://${domain}:${port}/refresh-feeds`, true);
  xhr.send();
  notie.alert({type: 'info', text: 'Refreshing feeds...'});
  xhr.onload = () => {
    window.location.reload();
  };
};

let deleteFeed = (feedId, feedTitle) => {

  notie.confirm({
    text: `Are you sure you want to <b>delete</b> ${feedTitle}?!`,
    cancelCallback: function () {
      return;
    },
    submitCallback: function () {
      let xhr = new XMLHttpRequest();
      const domain = window.location.hostname;
      const port = location.port;
      let formData = new FormData();
      formData.append("feed_id", feedId);

      xhr.open("POST", `http://${domain}:${port}/delete-feed`, true);
      xhr.send(formData);
      xhr.onload = () => {
        window.location = "/";
      }
      }
    })
};

let updateItemClassToRead = (itemId) => {
  const itemDiv = document.getElementById(`item-${itemId}`);
  itemDiv.classList.add("is-read");
};