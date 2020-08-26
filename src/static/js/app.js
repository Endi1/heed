let markAsRead = (itemId) => {
  let xhr = new XMLHttpRequest();
  const domain = window.location.hostname;
  const port = location.port;
  let formData = new FormData();
  formData.append("item_id", itemId);

  xhr.open("POST", `http://${domain}:${port}/mark-read`, true);
  xhr.send(formData);
};
