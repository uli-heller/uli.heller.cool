- <a href="#" onclick="toggleTop(event);" id="show_hide">&Uarr;</a>
- [GPS-Vergleich Garmin 6X/7X](garmin-6x-7x/index.md)

# Trenner

- [Impressum](impressum.md)

<script>
 function toggleTop(e) {
    var top=document.getElementById("headermd");
    var show_hide=document.getElementById("show_hide");
    if (top.style.display === "none") {
        top.style.display = "block";
        show_hide.innerHTML="&Uarr;"
    } else {
        top.style.display = "none";
        show_hide.innerHTML="&Darr;"
    }
    e.preventDefault();
  }
</script>
