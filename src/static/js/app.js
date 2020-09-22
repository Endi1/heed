let markAsRead = (itemId) => {
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
  xhr.onload = () => {
    window.location.reload();
  };
};

let deleteFeed = (feedId) => {
  let xhr = new XMLHttpRequest();
  const domain = window.location.hostname;
  const port = location.port;
  let formData = new FormData();
  formData.append("feed_id", feedId);

  xhr.open("POST", `http://${domain}:${port}/delete-feed`, true);
  xhr.send(formData);
};
