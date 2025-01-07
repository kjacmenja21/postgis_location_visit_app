// Collapsible functionality
document.addEventListener("DOMContentLoaded", function () {
  var coll = document.getElementsByClassName("collapsible");

  // Attach click event listener to each collapsible button
  for (var i = 0; i < coll.length; i++) {
    coll[i].addEventListener("click", function () {
      this.classList.toggle("active");
      var content = this.nextElementSibling;
      if (content.style.display === "block") {
        content.style.display = "none";
      } else {
        content.style.display = "block";
      }
    });
  }
});
