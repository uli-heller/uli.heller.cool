- <a href="#" onclick="toggleTop(event);" id="show_hide">&Uarr;</a>
- [README](README.md)
- [index](index.md)
- [Eins](eins.md)
- [Zwei](zwei.md)
- [Drei](drei.md)

# Trenner

- [Rechts](rechts.md)

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
