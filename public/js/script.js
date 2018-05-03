function start(){
    window.location= "/shop"
 
}

function filter() {
    var selectBox = document.getElementById("filter");
    var selectedValue = selectBox.options[selectBox.selectedIndex].value;
    var table = document.getElementById("table");
    var x = table.getElementsByTagName("td");
    var i;
    for (i = 0; i < x.length; i++) { 
        if (selectedValue == "All"){
            x[i].style.display = "";
        } else{
        if (x[i].innerHTML.indexOf(selectedValue) > -1){         
            x[i].style.display = "";
        }else{
            x[i].style.display = "none";
        }
    }
    }
   }


